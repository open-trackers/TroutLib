//
//  ZUtils.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

/// Ensure all the records have archiveIDs
/// NOTE: does NOT save context
public func updateArchiveIDs(_ context: NSManagedObjectContext) throws {
    let pred = NSPredicate(format: "archiveID == NULL")
    try context.fetcher(predicate: pred) { (routine: MRoutine) in
        if let _ = routine.archiveID { return true }
        routine.archiveID = UUID()
        return true
    }
    try context.fetcher(predicate: pred) { (task: MTask) in
        if let _ = task.archiveID { return true }
        task.archiveID = UUID()
        return true
    }
}

/// Ensure all the records have createdAts
/// NOTE: does NOT save context
public func updateCreatedAts(_ context: NSManagedObjectContext) throws {
    let pred = NSPredicate(format: "createdAt == NULL")
    try context.fetcher(predicate: pred) { (element: MRoutine) in
        if let _ = element.createdAt { return true }
        element.createdAt = Date.now
        return true
    }
    try context.fetcher(predicate: pred) { (element: MTask) in
        if let _ = element.createdAt { return true }
        element.createdAt = Date.now
        return true
    }
    try context.fetcher(predicate: pred) { (element: ZTask) in
        if let _ = element.createdAt { return true }
        element.createdAt = Date.now
        return true
    }
    try context.fetcher(predicate: pred) { (element: ZTaskRun) in
        if let _ = element.createdAt { return true }
        element.createdAt = Date.now
        return true
    }
    try context.fetcher(predicate: pred) { (element: ZRoutine) in
        if let _ = element.createdAt { return true }
        element.createdAt = Date.now
        return true
    }
    try context.fetcher(predicate: pred) { (element: ZRoutineRun) in
        if let _ = element.createdAt { return true }
        element.createdAt = Date.now
        return true
    }
    try context.fetcher(predicate: pred) { (element: AppSetting) in
        if let _ = element.createdAt { return true }
        element.createdAt = Date.now
        return true
    }
}

/// Delete all `Z` records prior to a specified date.
/// NOTE: does NOT save context
public func cleanLogRecords(_ context: NSManagedObjectContext, keepSince: Date, inStore: NSPersistentStore) throws {
    let pred = NSPredicate(format: "startedAt < %@", keepSince as NSDate)

    try context.fetcher(predicate: pred, inStore: inStore) { (element: ZRoutineRun) in
        context.delete(element)
        return true
    }

    // TODO: delete orphaned ZTask and ZRoutine

    // no longer using deleter due to errors not occurring with plain old delete
//    try context.deleter(ZTaskRun.self,
//                        predicate: NSPredicate(format: "completedAt < %@", keepSince as NSDate))
//
//    try context.deleter(ZTask.self,
//                        predicate: NSPredicate(format: "zTaskRuns.@count == 0"))
//
//    try context.deleter(ZRoutineRun.self,
//                        predicate: NSPredicate(format: "startedAt < %@", keepSince as NSDate))
//
//    try context.deleter(ZRoutine.self,
//                        predicate: NSPredicate(format: "zRoutineRuns.@count == 0"))
}
