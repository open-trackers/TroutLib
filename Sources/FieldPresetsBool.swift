//
//  FieldPresetsBool.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Collections
import Foundation

public typealias FieldPresetBoolDict = OrderedDictionary<FieldGroupBool, [FieldPreset<AnyHashable>]>

private let initialValue: Bool = false

// see README for guidelines on adding/maintaining these presets.
public let fieldPresetsBool: FieldPresetBoolDict = [
    .progress: [
        FieldPreset("Has Completed", initialValue: initialValue),
    ],
    .journey: [
        FieldPreset("Has Started", initialValue: initialValue),
        FieldPreset("Is En Route", initialValue: initialValue),
        FieldPreset("Has Finished", initialValue: initialValue),
    ],
    .power: [
        FieldPreset("Is Powered On", initialValue: initialValue),
        FieldPreset("Is Powered Off", initialValue: initialValue),
    ],
    .location: [
        FieldPreset("Is At Home", initialValue: initialValue),
        FieldPreset("Is At Work", initialValue: initialValue),
    ],
    .status: [
        FieldPreset("Is Damaged", initialValue: initialValue),
        FieldPreset("Is Intact", initialValue: initialValue),
        FieldPreset("Is Leaking", initialValue: initialValue),
        FieldPreset("Is Safe", initialValue: initialValue),
        FieldPreset("Is NOT Safe", initialValue: initialValue),
    ],
]
