//
//  ZField.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

/// Archive representation of a MField record
public extension ZField {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       zTask: ZTask,
                       fieldArchiveID: UUID,
                       fieldName: String? = nil,
                       unitsSuffix: String? = nil,
                       createdAt: Date? = Date.now,
                       toStore: NSPersistentStore) -> ZField
    {
        let nu = ZField(context: context)
        zTask.addToZFields(nu)
        nu.createdAt = createdAt
        nu.name = fieldName
        nu.unitsSuffix = unitsSuffix
        nu.fieldArchiveID = fieldArchiveID
        context.assign(nu, to: toStore)
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// NOTE: assumes that routine is in dstStore.
    /// Does not delete self.
    /// Does NOT save context.
    func shallowCopy(_ context: NSManagedObjectContext,
                     dstTask: ZTask,
                     toStore dstStore: NSPersistentStore) throws -> ZField
    {
        guard let fieldArchiveID
        else { throw TrackerError.missingData(msg: "fieldArchiveID; can't copy") }
        let nu = try ZField.getOrCreate(context,
                                        zTask: dstTask,
                                        fieldArchiveID: fieldArchiveID,
                                        inStore: dstStore)
        { _, element in
            element.name = wrappedName
            element.createdAt = createdAt
            element.unitsSuffix = unitsSuffix
        }
        return nu
    }
}

public extension ZField {
    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }

    var fieldRunsArray: [ZFieldRun] {
        (zFieldRuns?.allObjects as? [ZFieldRun]) ?? []
    }
}
