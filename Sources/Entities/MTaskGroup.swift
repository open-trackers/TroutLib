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

@objc(MTaskGroup)
public class MTaskGroup: NSManagedObject {}

extension MTaskGroup: UserOrdered {}

public extension MTaskGroup {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       routine: MRoutine,
                       userOrder: Int16,
                       groupRaw: Int16,
                       createdAt: Date = Date.now) -> MTaskGroup
    {
        let nu = MTaskGroup(context: context)
        routine.addToTaskGroups(nu)
        nu.createdAt = createdAt
        nu.userOrder = userOrder
        nu.groupRaw = groupRaw
        return nu
    }
}
