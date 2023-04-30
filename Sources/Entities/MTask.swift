//
//  MTask.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

@objc(MTask)
public class MTask: NSManagedObject {}

public extension MTask {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       routine: MRoutine,
                       userOrder: Int16,
                       name: String = "New Task",
                       archiveID: UUID = UUID(),
                       createdAt: Date = Date.now) -> MTask
    {
        let nu = MTask(context: context)
        routine.addToTasks(nu)
        nu.createdAt = createdAt
        nu.userOrder = userOrder
        nu.name = name
        nu.archiveID = archiveID
        return nu
    }

    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }

    var fieldsArray: [MField] {
        (fields?.allObjects as? [MField]) ?? []
    }
}

public extension MTask {
    // Bulk creation of tasks, from task preset multi-select on iOS.
    // NOTE: does NOT save context
    static func bulkCreate(_ context: NSManagedObjectContext,
                           routine: MRoutine,
                           presets: [TaskPreset],
                           createdAt: Date = Date.now) throws
    {
        var userOrder = try (Self.maxUserOrder(context, routine: routine)) ?? 0
        try presets.forEach { preset in
            userOrder += 1

            let task = MTask.create(context,
                                    routine: routine,
                                    userOrder: userOrder,
                                    name: preset.text,
                                    createdAt: createdAt)

            try task.populate(context, from: preset)
        }
    }
}

public extension MTask {
    var isDone: Bool {
        lastCompletedAt != nil
    }

    var isNotDone: Bool {
        !isDone
    }

    // NOTE: does NOT save context
    func clearFields(_ context: NSManagedObjectContext) {
        fieldsArray.forEach {
            self.removeFromFields($0)
            context.delete($0)
        }
    }
}

public extension MTask {
    // NOTE: does NOT save context
    func populate(_ context: NSManagedObjectContext, from preset: TaskPreset) throws {
        clearFields(context)

        var userOrder: Int16 = 0
        try preset.fields.forEach {
            try MField.create(context, task: self, from: $0, userOrder: userOrder)
            userOrder += 1
        }
    }
}

public extension MTask {
    // NOTE: does NOT save context
    func move(_ context: NSManagedObjectContext, to nu: MRoutine) throws {
        let nuMaxOrder = try MTask.maxUserOrder(context, routine: nu) ?? 0
        if let old = routine { old.removeFromTasks(self) }
        userOrder = nuMaxOrder + 1
        nu.addToTasks(self)
    }
}
