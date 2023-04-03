//
//  CoreDataStack-clear.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension CoreDataStack {
    /// Clear Categories and Servings from the main store. (Should not be present in Archive store.)
    /// NOTE: does NOT save context
    func clearPrimaryEntities(_ context: NSManagedObjectContext) throws {
        try context.deleter(MField.self)
        try context.deleter(MTask.self)
        try context.deleter(MTaskGroup.self)
        try context.deleter(MRoutine.self)
        try context.deleter(AppSetting.self)
    }

    /// Clear the log entities from the specified store.
    /// If no store specified, it will clear from all stores.
    /// NOTE: does NOT save context
    public func clearZEntities(_ context: NSManagedObjectContext, inStore: NSPersistentStore? = nil) throws {
        try context.deleter(ZFieldRun.self, inStore: inStore)
        try context.deleter(ZField.self, inStore: inStore)
        try context.deleter(ZTaskRun.self, inStore: inStore)
        try context.deleter(ZTask.self, inStore: inStore)
        try context.deleter(ZRoutineRun.self, inStore: inStore)
        try context.deleter(ZRoutine.self, inStore: inStore)
    }
}
