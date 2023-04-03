//
//  ZTaskRun.swift
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
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       zRoutineRun: ZRoutineRun,
                       zTask: ZTask,
                       completedAt: Date,
                       createdAt: Date? = Date.now,
                       toStore: NSPersistentStore) -> ZTaskRun
    {
        let nu = ZTaskRun(context: context)
        zRoutineRun.addToZTaskRuns(nu)
        zTask.addToZTaskRuns(nu)
        nu.createdAt = createdAt
        nu.completedAt = completedAt
        context.assign(nu, to: toStore)
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// Does not delete self.
    /// Does NOT save context.
    func shallowCopy(_ context: NSManagedObjectContext,
                     dstRoutineRun: ZRoutineRun,
                     dstTask: ZTask,
                     toStore dstStore: NSPersistentStore) throws -> ZTaskRun
    {
        guard let completedAt
        else { throw TrackerError.missingData(msg: "completedAt not present; can't copy") }
        return try ZTaskRun.getOrCreate(context,
                                        zRoutineRun: dstRoutineRun,
                                        zTask: dstTask,
                                        completedAt: completedAt,
                                        inStore: dstStore)
        { _, element in
            element.userRemoved = userRemoved
            element.createdAt = createdAt
        }
    }
}

public extension ZTaskRun {
    /// Like a delete, but allows the mirroring to archive and iCloud to properly
    /// reflect that the user 'deleted' the record(s) from the store(s).
    static func userRemove(_ context: NSManagedObjectContext,
                           taskArchiveID: UUID,
                           completedAt: Date,
                           inStore: NSPersistentStore? = nil) throws
    {
        let pred = getPredicate(taskArchiveID: taskArchiveID, completedAt: completedAt)
        let sort = byCreatedAt()
        try context.fetcher(predicate: pred, sortDescriptors: sort, inStore: inStore) { (element: ZTaskRun) in
            element.userRemoved = true

            let pred2 = ZFieldRun.getPredicate(zTaskRun: element)
            let sort2 = ZFieldRun.byCreatedAt()

            try context.fetcher(predicate: pred2, sortDescriptors: sort2, inStore: inStore) { (element: ZFieldRun) in
                element.userRemoved = true
                return true
            }

            return true
        }
    }
}
