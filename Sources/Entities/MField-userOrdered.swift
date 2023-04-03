//
//  MField-userOrdered.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension MField: UserOrdered {}

public extension MField {
    static func maxUserOrder(_ context: NSManagedObjectContext, task: MTask) throws -> Int16? {
        let sort = MField.byUserOrder(ascending: false)
        let pred = MField.getPredicate(task: task)
        let task: MField? = try context.firstFetcher(predicate: pred, sortDescriptors: sort)
        return task?.userOrder
    }
}
