//
//  MField-preset.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension MField {
    /// Create a MField\* from a FieldPreset
    static func create(_ context: NSManagedObjectContext,
                       task: MTask,
                       from preset: FieldPreset<AnyHashable>,
                       userOrder: Int16) throws
    {
        if let iv = preset.initialValue as? Bool {
            _ = MFieldBool.create(context,
                                  task: task,
                                  name: preset.text,
                                  userOrder: userOrder,
                                  clearOnRun: true,
                                  value: iv)
        } else if let iv = preset.initialValue as? Int16 {
            let stepValue: Int16 = (preset.stepValue as? Int16) ?? 1
            let upperBound: Int16 = (preset.upperBound as? Int16) ?? Int16.max
            _ = MFieldInt16.create(context,
                                   task: task,
                                   name: preset.text,
                                   userOrder: userOrder,
                                   unitsSuffix: preset.unitsSuffix,
                                   clearOnRun: true,
                                   defaultValue: iv,
                                   value: iv,
                                   upperBound: upperBound,
                                   stepValue: stepValue)
        } else {
            throw TrackerError.invalidData(msg: "Unrecognized Field Preset.")
        }
    }

    func update(_: NSManagedObjectContext, from preset: FieldPreset<AnyHashable>) throws {
        name = preset.text
        unitsSuffix = preset.unitsSuffix

        if let iv = preset.initialValue as? Bool,
           let me = self as? MFieldBool
        {
            me.value = iv
        } else if let iv = preset.initialValue as? Int16,
                  let me = self as? MFieldInt16
        {
            let stepValue: Int16 = (preset.stepValue as? Int16) ?? 1
            let upperBound: Int16 = (preset.upperBound as? Int16) ?? Int16.max

            me.stepValue = stepValue
            me.upperBound = upperBound
            me.value = iv

        } else {
            throw TrackerError.invalidData(msg: "Unrecognized Field Preset.")
        }
    }
}
