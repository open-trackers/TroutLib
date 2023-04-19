//
//  MRoutine-startStopRun.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension MRoutine {
    // NOTE: does NOT save context
    func clearState(_ context: NSManagedObjectContext) throws {
        lastStartedAt = nil
        pausedAt = nil
        lastDuration = 0

        try clearTaskCompletions(context)
    }

    // Resets fields to defaults, where their clear flag is set
    // NOTE: does NOT save context
    internal func clearTaskCompletions(_ context: NSManagedObjectContext) throws {
        let taskPred = MTask.getPredicate(routine: self)
        let taskSort = MTask.byCreatedAt()
        try context.fetcher(predicate: taskPred, sortDescriptors: taskSort) { (task: MTask) in
            task.lastCompletedAt = nil

            let fieldPred = MField.getPredicate(task: task)
            let fieldSort = MField.byCreatedAt()
            try context.fetcher(predicate: fieldPred, sortDescriptors: fieldSort) { (field: MField) in

                guard field.clearOnRun else { return true }

                if let boolField = field as? MFieldBool {
                    boolField.value = false
                } else if let int16Field = field as? MFieldInt16 {
                    int16Field.value = int16Field.defaultValue
                }

                return true
            }
            return true
        }
    }

    // NOTE: not setting lastStartedAt or resumedAt yet to ignore mistaken starts.
    // NOTE: does NOT save context
    func startOrResumeRun(_ context: NSManagedObjectContext, now: Date = Date.now) throws -> Date {
        guard !isTemplate else { throw TrackerError.invalidAction(msg: "Cannot start (or resume) a template.") }

        if pausedAt == nil {
            // starting anew, so clear task completions
            try clearTaskCompletions(context)
        }

        return now
    }

    // NOTE: does NOT save context
    func stopRun(startedOrResumedAt: Date, pause: Bool, now: Date = Date.now) throws {
        // NOTE: the user may have inadvertently started the routine and not completed any tasks. (lastStartedAt and lastDuration will be preserved from previous run.)
        guard hasCompletedAtLeastOneTask else {
            pausedAt = nil
            return
        }

        // store the time accumulated since the last start
        let elapsedTime = now.timeIntervalSince(startedOrResumedAt)
        if pausedAt != nil {
            lastDuration += elapsedTime
        } else {
            lastDuration = elapsedTime
        }

        pausedAt = pause ? now : nil
    }
}
