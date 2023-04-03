//
//  ZTaskRun-fetch.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension ZTaskRun {
    static func getPredicate(zRoutineRun: ZRoutineRun) -> NSPredicate {
        NSPredicate(format: "zRoutineRun == %@", zRoutineRun)
    }

    static func getPredicate(zRoutineRun: ZRoutineRun,
                             userRemoved: Bool) -> NSPredicate
    {
        NSPredicate(format: "zRoutineRun == %@ AND userRemoved == %@", zRoutineRun, NSNumber(value: userRemoved))
    }

    static func getPredicate(taskArchiveID: UUID,
                             completedAt: Date) -> NSPredicate
    {
        NSPredicate(format: "zTask.taskArchiveID = %@ AND completedAt == %@",
                    taskArchiveID as NSUUID,
                    completedAt as NSDate)
    }
}

public extension ZTaskRun {
    static func byCreatedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \ZTaskRun.createdAt, ascending: ascending),
        ]
    }

    static func byCompletedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \ZTaskRun.completedAt, ascending: ascending),
            NSSortDescriptor(keyPath: \ZTaskRun.createdAt, ascending: true),
        ]
    }
}

extension ZTaskRun {
    static func get(_ context: NSManagedObjectContext,
                    taskArchiveID: UUID,
                    completedAt: Date,
                    inStore: NSPersistentStore? = nil) throws -> ZTaskRun?
    {
        let pred = getPredicate(taskArchiveID: taskArchiveID, completedAt: completedAt)
        let sort = byCreatedAt()
        return try context.firstFetcher(predicate: pred, sortDescriptors: sort, inStore: inStore)
    }

    /// Fetch a ZTaskRun record in the specified store, creating if necessary.
    /// Will update intensity on existing record.
    /// Will NOT update ZRoutineRun on existing record.
    /// NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            zRoutineRun: ZRoutineRun,
                            zTask: ZTask,
                            completedAt: Date,
                            inStore: NSPersistentStore,
                            onUpdate: (Bool, ZTaskRun) -> Void = { _, _ in }) throws -> ZTaskRun
    {
        guard let taskArchiveID = zTask.taskArchiveID
        else { throw TrackerError.missingData(msg: "ZTask.archiveID; can't get or create") }

        if let existing = try ZTaskRun.get(context, taskArchiveID: taskArchiveID, completedAt: completedAt, inStore: inStore) {
            onUpdate(true, existing)
            return existing
        } else {
            let nu = ZTaskRun.create(context, zRoutineRun: zRoutineRun, zTask: zTask, completedAt: completedAt, toStore: inStore)
            onUpdate(false, nu)
            return nu
        }
    }

    static func count(_ context: NSManagedObjectContext,
                      predicate: NSPredicate? = nil,
                      inStore: NSPersistentStore? = nil) throws -> Int
    {
        try context.counter(ZTaskRun.self, predicate: predicate, inStore: inStore)
    }
}
