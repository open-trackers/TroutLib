//
//  ZTask.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

/// Archive representation of a MTask record
public extension ZTask {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       zRoutine: ZRoutine,
                       taskArchiveID: UUID,
                       taskName: String? = nil,
                       createdAt: Date? = Date.now,
                       toStore: NSPersistentStore) -> ZTask
    {
        let nu = ZTask(context: context)
        zRoutine.addToZTasks(nu)
        nu.createdAt = createdAt
        nu.name = taskName
        nu.taskArchiveID = taskArchiveID
        context.assign(nu, to: toStore)
        return nu
    }

    /// Shallow copy of self to specified store, returning newly copied record (residing in dstStore).
    /// NOTE: assumes that routine is in dstStore.
    /// Does not delete self.
    /// Does NOT save context.
    func shallowCopy(_ context: NSManagedObjectContext,
                     dstRoutine: ZRoutine,
                     toStore dstStore: NSPersistentStore) throws -> ZTask
    {
        guard let taskArchiveID
        else { throw TrackerError.missingData(msg: "taskArchiveID; can't copy") }
        let nu = try ZTask.getOrCreate(context,
                                       zRoutine: dstRoutine,
                                       taskArchiveID: taskArchiveID,
                                       inStore: dstStore)
        { _, element in
            element.name = wrappedName
            // element.units = units
            element.createdAt = createdAt
        }
        return nu
    }
}

public extension ZTask {
    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }

    var taskRunsArray: [ZTaskRun] {
        (zTaskRuns?.allObjects as? [ZTaskRun]) ?? []
    }
}
