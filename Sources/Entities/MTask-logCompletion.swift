//
//  MTask-logCompletion.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension MTask {
    /// log the run of the task to the main store
    /// (These will later be transferred to the archive store on iOS devices)
    ///
    /// If ZRoutineRun for the task has been deleted, possibly on another device,
    /// it's userRemoved flag will be set back to 'false'.
    ///
    /// NOTE: startedAt should be when the routine was originally started,
    ///       ignoring pauses.  This is the unique key for a routine run.
    ///
    /// NOTE: elapsedSecs should ignore time elapsed while routine was paused.
    ///
    /// NOTE: does NOT save context
    func logCompletion(_ context: NSManagedObjectContext,
                       mainStore: NSPersistentStore,
                       startedAt: Date,
                       elapsedSecs: TimeInterval,
                       taskCompletedAt: Date) throws
    {
        guard let routine else {
            throw TrackerError.missingData(msg: "Unexpectedly no routine. Cannot log task run.")
        }

        // Get corresponding ZRoutine for log, creating if necessary.
        let routineArchiveID: UUID = {
            if routine.archiveID == nil {
                routine.archiveID = UUID()
            }
            return routine.archiveID!
        }()
        let zRoutine = try ZRoutine.getOrCreate(context,
                                                routineArchiveID: routineArchiveID,
                                                // routineName: routine.wrappedName,
                                                inStore: mainStore)
        { _, element in
            element.name = routine.wrappedName
        }

        // Get corresponding ZTask for log, creating if necessary.
        let taskArchiveID: UUID = {
            if self.archiveID == nil {
                self.archiveID = UUID()
            }
            return self.archiveID!
        }()
        let zTask = try ZTask.getOrCreate(context,
                                          zRoutine: zRoutine,
                                          taskArchiveID: taskArchiveID,
                                          // taskName: wrappedName,
                                          // taskUnits: Units(rawValue: units) ?? .none,
                                          inStore: mainStore)
        { _, element in
            element.name = wrappedName
//            element.units = units
        }

        let zRoutineRun = try ZRoutineRun.getOrCreate(context,
                                                      zRoutine: zRoutine,
                                                      startedAt: startedAt,
                                                      inStore: mainStore)
        { _, element in
            element.elapsedSecs = elapsedSecs

            // removal may have happened on another device; we're reversing it
            element.userRemoved = false
        }

        let zTaskRun = try ZTaskRun.getOrCreate(context,
                                                zRoutineRun: zRoutineRun,
                                                zTask: zTask,
                                                completedAt: taskCompletedAt,
                                                // intensity: taskIntensity,
                                                inStore: mainStore)
        { _, _ in
//            element.intensity = taskIntensity
        }

        let fieldPred = MField.getPredicate(task: self)
        let fieldSort = MField.byUserOrder()

        try context.fetcher(predicate: fieldPred, sortDescriptors: fieldSort, inStore: mainStore) { (field: MField) in

            guard let fieldArchiveID = field.archiveID else { return true }

            let zField = try ZField.getOrCreate(context, zTask: zTask, fieldArchiveID: fieldArchiveID, inStore: mainStore) { _, element in
                element.name = field.name
                element.unitsSuffix = field.unitsSuffix
            }

            let stringValue = field.valueAsString()

            _ = try ZFieldRun.getOrCreate(context, zTaskRun: zTaskRun, zField: zField, inStore: mainStore) { _, element in

                element.value = stringValue
                element.userRemoved = false
            }

            return true
        }

        // update the widget(s), if any
        try WidgetEntry.refresh(context,
                                reload: true,
                                defaultColor: .accentColor)
    }
}
