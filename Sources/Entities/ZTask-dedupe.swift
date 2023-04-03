
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

extension ZTask {
    internal static func dedupe(_ context: NSManagedObjectContext,
                                routineArchiveID: UUID,
                                taskArchiveID: UUID,
                                inStore: NSPersistentStore) throws
    {
        let pred = getPredicate(routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID)
        let sort = ZTask.byCreatedAt()
        var first: ZTask?
        try context.fetcher(predicate: pred, sortDescriptors: sort, inStore: inStore) { (element: ZTask) in

            if let _first = first {
                for taskRun in element.taskRunsArray {
                    element.removeFromZTaskRuns(taskRun)
                    _first.addToZTaskRuns(taskRun)
                }
                context.delete(element)
            } else {
                first = element
            }
            return true
        }
    }

    // NOTE: does NOT save context
    // NOTE: does NOT dedupe zTaskRuns
    // Consolidates zTaskRuns under the earliest ZTask dupe.
    public static func dedupe(_ context: NSManagedObjectContext, _ object: NSManagedObject, inStore: NSPersistentStore) throws {
        guard let element = object as? ZTask,
              let routineArchiveID = element.zRoutine?.routineArchiveID,
              let taskArchiveID = element.taskArchiveID
        else { throw TrackerError.missingData(msg: "Could not resolve ZTask for de-duplication.") }

        try ZTask.dedupe(context, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: inStore)
    }
}
