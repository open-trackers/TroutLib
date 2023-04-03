
//
//  MField.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension MField {
    internal static func dedupe(_ context: NSManagedObjectContext,
                                taskArchiveID: UUID,
                                fieldArchiveID: UUID) throws
    {
        let pred = getPredicate(taskArchiveID: taskArchiveID,
                                fieldArchiveID: fieldArchiveID)
        let sort = byCreatedAt()
        var first: MField?
        // let count = try context.counter(MField.self, predicate: pred)
        try context.fetcher(predicate: pred, sortDescriptors: sort) { (element: MField) in
            if first == nil {
                first = element
            } else {
                context.delete(element)
            }
            return true
        }
    }

    // NOTE: does NOT save context
    public static func dedupe(_ context: NSManagedObjectContext,
                              _ object: NSManagedObject) throws
    {
        guard let element = object as? MField
        else {
            throw TrackerError.missingData(msg: "Could not resolve MField for de-duplication.")
        }

        guard let taskArchiveID = element.task?.archiveID
        else {
            throw TrackerError.missingData(msg: "Could not resolve MField.task.archiveID for de-duplication.")
        }

        guard let fieldArchiveID = element.archiveID
        else {
            throw TrackerError.missingData(msg: "Could not resolve MField.archiveID for de-duplication.")
        }

        try MField.dedupe(context,
                          taskArchiveID: taskArchiveID,
                          fieldArchiveID: fieldArchiveID)
    }
}
