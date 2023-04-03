//
//  MTask-markDone.swift
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
    // NOTE: does NOT save context
    func markDone(_ context: NSManagedObjectContext,
                  mainStore: NSPersistentStore,
                  completedAt: Date = Date.now,
                  routineStartedOrResumedAt: Date,
                  logToHistory: Bool) throws
    {
        guard let routine
        else {
            throw TrackerError.missingData(msg: "Unexpectedly no valid routine. Cannot mark task done.")
        }

        // Because the user completed a task, we can assume that start of
        // the task isn't accidental, we can now save the start time.
        if routine.pausedAt == nil {
            routine.lastStartedAt = routineStartedOrResumedAt
            routine.lastDuration = 0
        }

        // elapsed seconds, relative to the start time, excluding any paused periods.
        let elapsedSecs = routine.lastDuration + completedAt.timeIntervalSince(routineStartedOrResumedAt)

        // Log the completion of the task for the historical record.
        // NOTE: can update MRoutine and create/update ZRoutine, ZRoutineRun, and ZTaskRun.
        if logToHistory,
           let startedAt = routine.lastStartedAt
        {
            try logCompletion(context,
                              mainStore: mainStore,
                              startedAt: startedAt,
                              elapsedSecs: elapsedSecs,
                              taskCompletedAt: completedAt)
        }

        lastCompletedAt = completedAt
    }
}
