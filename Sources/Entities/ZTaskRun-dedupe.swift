
//
//  ZTaskRun-dedupe.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension ZTaskRun {
    static func dedupe(_ context: NSManagedObjectContext,
                       taskArchiveID: UUID,
                       completedAt: Date,
                       inStore: NSPersistentStore) throws
    {
        let pred = getPredicate(taskArchiveID: taskArchiveID,
                                completedAt: completedAt)
        let sort = byCreatedAt()
        var first: ZTaskRun?
        try context.fetcher(predicate: pred, sortDescriptors: sort, inStore: inStore) { (element: ZTaskRun) in
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
                              _ object: NSManagedObject,
                              inStore: NSPersistentStore) throws
    {
        guard let element = object as? ZTaskRun
        else {
            throw TrackerError.missingData(msg: "Could not resolve ZTaskRun for de-duplication.")
        }

        guard let taskArchiveID = element.zTask?.taskArchiveID
        else {
            throw TrackerError.missingData(msg: "Could not resolve ZTaskRun.taskArchiveID for de-duplication.")
        }

        guard let completedAt = element.completedAt
        else {
            throw TrackerError.missingData(msg: "Could not resolve ZTaskRun.completedAt for de-duplication.")
        }

        try ZTaskRun.dedupe(context,
                            taskArchiveID: taskArchiveID,
                            completedAt: completedAt,
                            inStore: inStore)
    }
}
