//
//  MField-fetch.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension MField {
    static func get(_ context: NSManagedObjectContext,
                    taskArchiveID: UUID,
                    archiveID: UUID) throws -> MField?
    {
        let pred = getPredicate(taskArchiveID: taskArchiveID, fieldArchiveID: archiveID)
        let sort = MField.byCreatedAt()
        return try context.firstFetcher(predicate: pred, sortDescriptors: sort)
    }
}

public extension MField {
    static func getPredicate(task: MTask) -> NSPredicate {
        NSPredicate(format: "task == %@", task)
    }

    static func getPredicate(taskArchiveID: UUID, fieldArchiveID: UUID) -> NSPredicate {
        NSPredicate(format: "task.archiveID == %@ AND archiveID == %@", taskArchiveID as NSUUID, fieldArchiveID as NSUUID)
    }
}

public extension MField {
    static func byCreatedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \MField.createdAt, ascending: ascending),
        ]
    }

    /// sort by userOrder(ascending/descending), createdAt(ascending)
    static func byUserOrder(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \MField.userOrder, ascending: ascending),
            NSSortDescriptor(keyPath: \MField.createdAt, ascending: true),
        ]
    }
}
