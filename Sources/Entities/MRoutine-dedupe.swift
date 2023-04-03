//
//  MRoutine-dedupe.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension MRoutine {
    internal static func dedupe(_ context: NSManagedObjectContext, archiveID: UUID) throws {
        let pred = getPredicate(archiveID: archiveID)
        let sort = byCreatedAt()
        var first: MRoutine?
        try context.fetcher(predicate: pred, sortDescriptors: sort) { (element: MRoutine) in
            if let _first = first {
                for task in element.tasksArray {
                    element.removeFromTasks(task)
                    _first.addToTasks(task)
                }
                for taskGroup in element.taskGroupsArray {
                    element.removeFromTaskGroups(taskGroup)
                    _first.addToTaskGroups(taskGroup)
                }
                context.delete(element)
            } else {
                first = element
            }
            return true
        }
    }

    // NOTE: does NOT save context
    // NOTE: does NOT dedupe tasks or foodGroups
    // Consolidates tasks and foodGroups under the earliest dupe.
    public static func dedupe(_ context: NSManagedObjectContext, _ object: NSManagedObject) throws {
        guard let element = object as? MRoutine,
              let archiveID = element.archiveID
        else { throw TrackerError.missingData(msg: "Could not resolve MRoutine for de-duplication.") }

        try MRoutine.dedupe(context, archiveID: archiveID)
    }
}
