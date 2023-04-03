//
//  ZFieldRun-fetch.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension ZFieldRun {
    static func getPredicate(zTaskRun: ZTaskRun) -> NSPredicate {
        NSPredicate(format: "zTaskRun == %@", zTaskRun)
    }

    static func getPredicate(zTaskRun: ZTaskRun,
                             userRemoved: Bool) -> NSPredicate
    {
        NSPredicate(format: "zTaskRun == %@ AND userRemoved == %@", zTaskRun, NSNumber(value: userRemoved))
    }

    static func getPredicate(fieldArchiveID: UUID,
                             completedAt: Date) -> NSPredicate
    {
        NSPredicate(format: "zField.fieldArchiveID = %@ AND zTaskRun.completedAt == %@",
                    fieldArchiveID as NSUUID,
                    completedAt as NSDate)
    }
}

public extension ZFieldRun {
    static func byCreatedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \ZFieldRun.createdAt, ascending: ascending),
        ]
    }

//    static func byCompletedAt(ascending: Bool = true) -> [NSSortDescriptor] {
//        [
//            NSSortDescriptor(keyPath: \ZFieldRun.completedAt, ascending: ascending),
//            NSSortDescriptor(keyPath: \ZFieldRun.createdAt, ascending: true),
//        ]
//    }
}

extension ZFieldRun {
    static func get(_ context: NSManagedObjectContext,
                    fieldArchiveID: UUID,
                    completedAt: Date,
                    inStore: NSPersistentStore? = nil) throws -> ZFieldRun?
    {
        let pred = getPredicate(fieldArchiveID: fieldArchiveID, completedAt: completedAt)
        let sort = byCreatedAt()
        return try context.firstFetcher(predicate: pred, sortDescriptors: sort, inStore: inStore)
    }

    /// Fetch a ZFieldRun record in the specified store, creating if necessary.
    /// Will NOT update ZTaskRun on existing record.
    /// NOTE: does NOT save context
    static func getOrCreate(_ context: NSManagedObjectContext,
                            zTaskRun: ZTaskRun,
                            zField: ZField,
                            // value _: String,
                            inStore: NSPersistentStore,
                            onUpdate: (Bool, ZFieldRun) -> Void = { _, _ in }) throws -> ZFieldRun
    {
        guard let fieldArchiveID = zField.fieldArchiveID
        else { throw TrackerError.missingData(msg: "ZField.archiveID; can't get or create") }

        guard let completedAt = zTaskRun.completedAt
        else { throw TrackerError.missingData(msg: "ZTaskRun is missing completedAt") }

        if let existing = try ZFieldRun.get(context, fieldArchiveID: fieldArchiveID, completedAt: completedAt, inStore: inStore) {
            onUpdate(true, existing)
            return existing
        } else {
            let nu = ZFieldRun.create(context, zTaskRun: zTaskRun, zField: zField, toStore: inStore)
            onUpdate(false, nu)
            return nu
        }
    }

    static func count(_ context: NSManagedObjectContext,
                      predicate: NSPredicate? = nil,
                      inStore: NSPersistentStore? = nil) throws -> Int
    {
        try context.counter(ZFieldRun.self, predicate: predicate, inStore: inStore)
    }
}
