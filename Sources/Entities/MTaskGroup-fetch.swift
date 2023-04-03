
//
//  MTaskGroup-fetch.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension MTaskGroup {
    static func getPredicate(routine: MRoutine) -> NSPredicate {
        NSPredicate(format: "routine == %@", routine)
    }

    static func getPredicate(routineArchiveID: UUID, groupRaw: Int16) -> NSPredicate {
        NSPredicate(format: "routine.archiveID == %@ AND groupRaw == %i", routineArchiveID as NSUUID, groupRaw)
    }
}

public extension MTaskGroup {
    static func byCreatedAt(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \MTaskGroup.createdAt, ascending: ascending),
        ]
    }

    /// sort by userOrder(ascending/descending), createdAt(ascending)
    static func byUserOrder(ascending: Bool = true) -> [NSSortDescriptor] {
        [
            NSSortDescriptor(keyPath: \MTaskGroup.userOrder, ascending: ascending),
            NSSortDescriptor(keyPath: \MTaskGroup.createdAt, ascending: true),
        ]
    }
}
