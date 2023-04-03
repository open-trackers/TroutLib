//
//  MFieldBool.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

@objc(MFieldBool)
public class MFieldBool: MField {}

public extension MFieldBool {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       task: MTask,
                       name: String,
                       userOrder: Int16,
                       clearOnRun: Bool = true,
                       archiveID: UUID = UUID(),
                       createdAt: Date = Date.now,
                       value: Bool) -> MFieldBool
    {
        let nu = MFieldBool(context: context)

        nu.create(fieldType: .bool,
                  controlType: .default,
                  task: task,
                  name: name,
                  userOrder: userOrder,
                  unitsSuffix: nil, // NOTE: no suffix used on bool values, or should there?
                  clearOnRun: clearOnRun,
                  archiveID: archiveID,
                  createdAt: createdAt)

        nu.value = value

        return nu
    }

    override func valueAsString() -> String {
        String(value)
    }
}
