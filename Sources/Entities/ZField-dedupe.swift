
//
//  ZField-dedupe.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension ZField {
    static func dedupe(_ context: NSManagedObjectContext,
                       taskArchiveID: UUID,
                       fieldArchiveID: UUID,
                       inStore: NSPersistentStore) throws
    {
        let pred = getPredicate(taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID)
        let sort = ZField.byCreatedAt()
        var first: ZField?
        try context.fetcher(predicate: pred, sortDescriptors: sort, inStore: inStore) { (element: ZField) in

            if let _first = first {
                for fieldRun in element.fieldRunsArray {
                    element.removeFromZFieldRuns(fieldRun)
                    _first.addToZFieldRuns(fieldRun)
                }
                context.delete(element)
            } else {
                first = element
            }
            return true
        }
    }

    // NOTE: does NOT save context
    // NOTE: does NOT dedupe zFieldRuns
    // Consolidates zFieldRuns under the earliest ZField dupe.
    public static func dedupe(_ context: NSManagedObjectContext, _ object: NSManagedObject, inStore: NSPersistentStore) throws {
        guard let element = object as? ZField,
              let taskArchiveID = element.zTask?.taskArchiveID,
              let fieldArchiveID = element.fieldArchiveID
        else { throw TrackerError.missingData(msg: "Could not resolve ZField for de-duplication.") }

        try ZField.dedupe(context, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: inStore)
    }
}
