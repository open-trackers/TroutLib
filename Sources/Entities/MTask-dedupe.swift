
//
//  MTask-dedupe.swift
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
    static func dedupe(_ context: NSManagedObjectContext, routineArchiveID: UUID, taskArchiveID: UUID) throws {
        let pred = getPredicate(routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID)
        let sort = MTask.byCreatedAt()
        var first: MTask?
        try context.fetcher(predicate: pred, sortDescriptors: sort) { (element: MTask) in
            if first == nil {
                first = element
            } else {
                context.delete(element)
            }
            return true
        }
    }

    // NOTE: does NOT save context
    // NOTE: does NOT dedupe routines
    public static func dedupe(_ context: NSManagedObjectContext, _ object: NSManagedObject) throws {
        guard let element = object as? MTask,
              let routineArchiveID = element.routine?.archiveID,
              let taskArchiveID = element.archiveID
        else { throw TrackerError.missingData(msg: "Could not resolve MTask for de-duplication.") }

        try MTask.dedupe(context,
                         routineArchiveID: routineArchiveID,
                         taskArchiveID: taskArchiveID)
    }
}
