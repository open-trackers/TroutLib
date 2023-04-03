//
//  MTask-fetch.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension MTask {
    static func get(_ context: NSManagedObjectContext,
                    routineArchiveID: UUID,
                    archiveID: UUID) throws -> MTask?
    {
        let pred = getPredicate(routineArchiveID: routineArchiveID, taskArchiveID: archiveID)
        let sort = MTask.byCreatedAt()
        return try context.firstFetcher(predicate: pred, sortDescriptors: sort)
    }
}

public extension MTask {
    static func getPredicate(routine: MRoutine) -> NSPredicate {
        NSPredicate(format: "routine == %@", routine)
    }

    static func getPredicate(routineArchiveID: UUID, taskArchiveID: UUID) -> NSPredicate {
        NSPredicate(format: "routine.archiveID == %@ AND archiveID == %@", routineArchiveID as NSUUID, taskArchiveID as NSUUID)
    }
}

public extension MTask {
    static func byCreatedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \MTask.createdAt, ascending: ascending),
        ]
    }

    /// sort by userOrder(ascending/descending), createdAt(ascending)
    static func byUserOrder(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \MTask.userOrder, ascending: ascending),
            NSSortDescriptor(keyPath: \MTask.createdAt, ascending: true),
        ]
    }
}
