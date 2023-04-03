//
//  ZTask-fetch.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension ZTask {
    static func getPredicate(zRoutine: ZRoutine) -> NSPredicate {
        NSPredicate(format: "zRoutine == %@", zRoutine)
    }

    static func getPredicate(routineArchiveID: UUID,
                             taskArchiveID: UUID) -> NSPredicate
    {
        NSPredicate(format: "zRoutine.routineArchiveID == %@ AND taskArchiveID == %@",
                    routineArchiveID as NSUUID,
                    taskArchiveID as NSUUID)
    }
}

public extension ZTask {
    static func byCreatedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \ZTask.createdAt, ascending: ascending),
        ]
    }
}

public extension ZTask {
    static func get(_ context: NSManagedObjectContext,
                    routineArchiveID: UUID,
                    taskArchiveID: UUID,
                    inStore: NSPersistentStore? = nil) throws -> ZTask?
    {
        let pred = getPredicate(routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID)
        let sort = byCreatedAt()
        return try context.firstFetcher(predicate: pred, sortDescriptors: sort, inStore: inStore)
    }

    /// Fetch a ZTask record in the specified store, creating if necessary.
    /// Will update name and units on existing record.
    /// Will NOT update ZRoutine on existing record.
    /// NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            zRoutine: ZRoutine,
                            taskArchiveID: UUID,
                            inStore: NSPersistentStore,
                            onUpdate: (Bool, ZTask) -> Void = { _, _ in }) throws -> ZTask
    {
        if let routineArchiveID = zRoutine.routineArchiveID,
           let existing = try ZTask.get(context,
                                        routineArchiveID: routineArchiveID,
                                        taskArchiveID: taskArchiveID,
                                        inStore: inStore)
        {
            onUpdate(true, existing)
            return existing
        } else {
            let nu = ZTask.create(context,
                                  zRoutine: zRoutine,
                                  taskArchiveID: taskArchiveID,
                                  toStore: inStore)
            onUpdate(false, nu)
            return nu
        }
    }
}
