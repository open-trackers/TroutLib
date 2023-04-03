//
//  MTask-userOrdered.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension MTask: UserOrdered {}

public extension MTask {
    static func maxUserOrder(_ context: NSManagedObjectContext, routine: MRoutine) throws -> Int16? {
        let sort = MTask.byUserOrder(ascending: false)
        let pred = MTask.getPredicate(routine: routine)
        let task: MTask? = try context.firstFetcher(predicate: pred, sortDescriptors: sort)
        return task?.userOrder
    }
}
