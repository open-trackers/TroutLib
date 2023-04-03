//
//  MFieldInt16.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

@objc(MFieldInt16)
public class MFieldInt16: MField {}

public extension MFieldInt16 {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       task: MTask,
                       name: String,
                       userOrder: Int16,
                       unitsSuffix: String? = nil,
                       clearOnRun: Bool = false,
                       archiveID: UUID = UUID(),
                       createdAt: Date = Date.now,
                       controlType: MField.ControlType = .default,
                       defaultValue: Int16 = 0,
                       value: Int16,
                       upperBound: Int16 = Int16.max,
                       stepValue: Int16 = 1) -> MFieldInt16
    {
        let nu = MFieldInt16(context: context)

        nu.create(fieldType: .int16,
                  controlType: controlType,
                  task: task,
                  name: name,
                  userOrder: userOrder,
                  unitsSuffix: unitsSuffix,
                  clearOnRun: clearOnRun,
                  archiveID: archiveID,
                  createdAt: createdAt)

        nu.defaultValue = defaultValue
        nu.value = value
        nu.upperBound = upperBound
        nu.stepValue = stepValue

        return nu
    }

    override func valueAsString() -> String {
        String(value)
    }
}
