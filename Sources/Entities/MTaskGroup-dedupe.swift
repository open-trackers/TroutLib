
//
//  MTaskGroup.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension MTaskGroup {
    internal static func dedupe(_ context: NSManagedObjectContext,
                                routineArchiveID: UUID,
                                groupRaw: Int16) throws
    {
        let pred = getPredicate(routineArchiveID: routineArchiveID, groupRaw: groupRaw)
        let sort = byCreatedAt()
        var first: MTaskGroup?
        try context.fetcher(predicate: pred, sortDescriptors: sort) { (element: MTaskGroup) in
            if first == nil {
                first = element
            } else {
                context.delete(element)
            }
            return true
        }
    }

    // NOTE: does NOT save context
    // NOTE: does NOT dedupe categories
    public static func dedupe(_ context: NSManagedObjectContext, _ object: NSManagedObject) throws {
        guard let element = object as? MTaskGroup,
              let archiveID = element.routine?.archiveID
        else { throw TrackerError.missingData(msg: "Could not resolve MTaskGroup for de-duplication.") }

        try MTaskGroup.dedupe(context,
                              routineArchiveID: archiveID,
                              groupRaw: element.groupRaw)
    }
}
