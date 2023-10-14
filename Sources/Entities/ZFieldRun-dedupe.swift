
//
//  ZFieldRun-dedupe.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension ZFieldRun {
    static func dedupe(_ context: NSManagedObjectContext,
                       fieldArchiveID: UUID,
                       completedAt: Date,
                       inStore: NSPersistentStore) throws
    {
        let pred = getPredicate(fieldArchiveID: fieldArchiveID,
                                completedAt: completedAt)
        let sort = byCreatedAt()
        var first: ZFieldRun?
        try context.fetcher(predicate: pred, sortDescriptors: sort, inStore: inStore) { (element: ZFieldRun) in
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
        guard let element = object as? ZFieldRun
        else {
            throw TrackerError.missingData(msg: "Could not resolve ZFieldRun for de-duplication.")
        }

        guard let fieldArchiveID = element.zField?.fieldArchiveID
        else {
            throw TrackerError.missingData(msg: "Could not resolve ZFieldRun.fieldArchiveID for de-duplication.")
        }

        guard let completedAt = element.zTaskRun?.completedAt
        else {
            throw TrackerError.missingData(msg: "Could not resolve ZFieldRun.completedAt for de-duplication.")
        }

        try ZFieldRun.dedupe(context,
                             fieldArchiveID: fieldArchiveID,
                             completedAt: completedAt,
                             inStore: inStore)
    }
}
