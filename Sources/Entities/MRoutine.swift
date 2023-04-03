//
//  MRoutine.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

@objc(MRoutine)
public class MRoutine: NSManagedObject {}

public extension MRoutine {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       userOrder: Int16,
                       name: String = "New Routine",
                       archiveID: UUID = UUID(),
                       createdAt: Date = Date.now) -> MRoutine
    {
        let nu = MRoutine(context: context)
        nu.createdAt = createdAt
        nu.userOrder = userOrder
        nu.name = name
        nu.archiveID = archiveID
        return nu
    }
}

public extension MRoutine {
    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }

    var tasksArray: [MTask] {
        (tasks?.allObjects as? [MTask]) ?? []
    }

    var taskGroupsArray: [MTaskGroup] {
        (taskGroups?.allObjects as? [MTaskGroup]) ?? []
    }
}

public extension MRoutine {
    var allComplete: Bool {
        tasksArray.count > 0 && tasksArray.allSatisfy(\.isDone)
    }

    var hasCompletedAtLeastOneTask: Bool {
        tasksArray.first(where: \.isDone) != nil
    }

    var completedTaskCount: Int {
        tasksArray.reduce(0) { $0 + ($1.isDone ? 1 : 0) }
    }

    var remainingTaskCount: Int {
        tasksArray.count - completedTaskCount
    }
}

public extension MRoutine {
    var filteredPresets: TaskPresetDict? {
        guard taskGroupsArray.count > 0 else { return nil }
        let taskGroups = taskGroupsArray.map { TaskGroup(rawValue: $0.groupRaw) }
        return taskPresets.filter { taskGroups.contains($0.key) }
    }
}
