//
//  MRoutine-fetch.swift
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
    static func get(_ context: NSManagedObjectContext,
                    archiveID: UUID) throws -> MRoutine?
    {
        let pred = getPredicate(archiveID: archiveID)
        let sort = MRoutine.byCreatedAt()
        return try context.firstFetcher(predicate: pred, sortDescriptors: sort)
    }

    static func getFirst(_ context: NSManagedObjectContext, sort: [NSSortDescriptor] = byUserOrder()) throws -> MRoutine? {
        try context.firstFetcher(sortDescriptors: sort)
    }
}

public extension MRoutine {
    static func getPredicate(archiveID: UUID) -> NSPredicate {
        NSPredicate(format: "archiveID == %@", archiveID as NSUUID)
    }
}

public extension MRoutine {
    static func byCreatedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \MRoutine.createdAt, ascending: ascending),
        ]
    }

    /// sort by userOrder(ascending/descending), createdAt(ascending)
    static func byUserOrder(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \MRoutine.userOrder, ascending: ascending),
            NSSortDescriptor(keyPath: \MRoutine.createdAt, ascending: true),
        ]
    }

    static func byLastStartedAt(ascending: Bool) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \MRoutine.lastStartedAt, ascending: ascending),
            NSSortDescriptor(keyPath: \MRoutine.createdAt, ascending: true),
        ]
    }

    static func byPausedAt(ascending: Bool) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \MRoutine.pausedAt, ascending: ascending),
            NSSortDescriptor(keyPath: \MRoutine.createdAt, ascending: true),
        ]
    }

    static func byName(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \MRoutine.name, ascending: ascending),
            NSSortDescriptor(keyPath: \MRoutine.createdAt, ascending: true),
        ]
    }
}

public extension MRoutine {
    // NOTE: does NOT save context
    static func getToRun(_ context: NSManagedObjectContext, _ originalURI: URL) throws -> MRoutine {
        guard let original: MRoutine = MRoutine.get(context, forURIRepresentation: originalURI) else {
            throw TrackerError.missingData(msg: "Routine not found.")
        }

        var routineToRun = original // will change if cloning!

        if original.isTemplate {
            routineToRun = try original.clone(context)
        }

        return routineToRun
    }
}
