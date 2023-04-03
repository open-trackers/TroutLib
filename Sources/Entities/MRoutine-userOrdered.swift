//
//  MRoutine-userOrdered.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension MRoutine: UserOrdered {}

public extension MRoutine {
    static func maxUserOrder(_ context: NSManagedObjectContext) throws -> Int16? {
        let sort = MRoutine.byUserOrder(ascending: false)
        let routine: MRoutine? = try context.firstFetcher(sortDescriptors: sort)
        return routine?.userOrder
    }
}
