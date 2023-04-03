//
//  ZFieldRun.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension ZFieldRun {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       zTaskRun: ZTaskRun,
                       zField: ZField,
                       createdAt: Date? = Date.now,
                       toStore: NSPersistentStore) -> ZFieldRun
    {
        let nu = ZFieldRun(context: context)
        zTaskRun.addToZFieldRuns(nu)
        zField.addToZFieldRuns(nu)
        nu.createdAt = createdAt
        context.assign(nu, to: toStore)
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// Does not delete self.
    /// Does NOT save context.
    func shallowCopy(_ context: NSManagedObjectContext,
                     dstTaskRun: ZTaskRun,
                     dstField: ZField,
                     toStore dstStore: NSPersistentStore) throws -> ZFieldRun
    {
        guard let value
        else { throw TrackerError.missingData(msg: "value not present; can't copy") }
        return try ZFieldRun.getOrCreate(context,
                                         zTaskRun: dstTaskRun,
                                         zField: dstField,
                                         // value: value,
                                         inStore: dstStore)
        { _, element in
            element.userRemoved = userRemoved
            element.value = value
            element.createdAt = createdAt
        }
    }
}

public extension ZFieldRun {
    /// Like a delete, but allows the mirroring to archive and iCloud to properly
    /// reflect that the user 'deleted' the record(s) from the store(s).
    static func userRemove(_ context: NSManagedObjectContext,
                           fieldArchiveID: UUID,
                           completedAt: Date,
                           inStore: NSPersistentStore? = nil) throws
    {
        let pred = getPredicate(fieldArchiveID: fieldArchiveID, completedAt: completedAt)
        let sort = byCreatedAt()
        try context.fetcher(predicate: pred, sortDescriptors: sort, inStore: inStore) { (element: ZFieldRun) in
            element.userRemoved = true
            return true
        }
    }
}
