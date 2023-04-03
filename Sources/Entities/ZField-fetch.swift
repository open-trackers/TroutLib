//
//  ZField-fetch.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension ZField {
    static func getPredicate(zTask: ZTask) -> NSPredicate {
        NSPredicate(format: "zTask == %@", zTask)
    }

    static func getPredicate(taskArchiveID: UUID,
                             fieldArchiveID: UUID) -> NSPredicate
    {
        NSPredicate(format: "zTask.taskArchiveID == %@ AND fieldArchiveID == %@",
                    taskArchiveID as NSUUID,
                    fieldArchiveID as NSUUID)
    }
}

public extension ZField {
    static func byCreatedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \ZField.createdAt, ascending: ascending),
        ]
    }
}

public extension ZField {
    static func get(_ context: NSManagedObjectContext,
                    taskArchiveID: UUID,
                    fieldArchiveID: UUID,
                    inStore: NSPersistentStore? = nil) throws -> ZField?
    {
        let pred = getPredicate(taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID)
        let sort = byCreatedAt()
        return try context.firstFetcher(predicate: pred, sortDescriptors: sort, inStore: inStore)
    }

    /// Fetch a ZField record in the specified store, creating if necessary.
    /// Will update name and units on existing record.
    /// Will NOT update ZTask on existing record.
    /// NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            zTask: ZTask,
                            fieldArchiveID: UUID,
                            inStore: NSPersistentStore,
                            onUpdate: (Bool, ZField) -> Void = { _, _ in }) throws -> ZField
    {
        if let taskArchiveID = zTask.taskArchiveID,
           let existing = try ZField.get(context,
                                         taskArchiveID: taskArchiveID,
                                         fieldArchiveID: fieldArchiveID,
                                         inStore: inStore)
        {
            onUpdate(true, existing)
            return existing
        } else {
            let nu = ZField.create(context,
                                   zTask: zTask,
                                   fieldArchiveID: fieldArchiveID,
                                   toStore: inStore)
            onUpdate(false, nu)
            return nu
        }
    }
}
