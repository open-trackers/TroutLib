//
//  FieldPresetsInt16.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Collections
import Foundation

public typealias FieldPresetInt16Dict = OrderedDictionary<FieldGroupInt16, [FieldPreset<AnyHashable>]>

private let initialValue: Int16 = 0
private let defaultUpperBound: Int16 = 1000

// see README for guidelines on adding/maintaining these presets.
public let fieldPresetsInt16: FieldPresetInt16Dict = [
    .quantity: [
        FieldPreset("Count", unitsSuffix: "", initialValue: initialValue, upperBound: defaultUpperBound),
        FieldPreset("Percent", unitsSuffix: "%", initialValue: initialValue, upperBound: defaultUpperBound),
        FieldPreset("Pair Count", unitsSuffix: "pr", initialValue: initialValue, upperBound: Int16(40)), // e.g., socks or pants
    ],
    .weight_metric: [
        FieldPreset("Weight", unitsSuffix: "g", initialValue: initialValue, upperBound: defaultUpperBound),
        FieldPreset("Weight", unitsSuffix: "kg", initialValue: initialValue, upperBound: defaultUpperBound),
    ],
    .weight_us: [
        FieldPreset("Weight", unitsSuffix: "oz", initialValue: initialValue, upperBound: defaultUpperBound),
        FieldPreset("Weight", unitsSuffix: "lb", initialValue: initialValue, upperBound: defaultUpperBound),
    ],
    .volume_metric: [
        FieldPreset("Volume", unitsSuffix: "ml", initialValue: initialValue, upperBound: defaultUpperBound),
        FieldPreset("Volume", unitsSuffix: "l", initialValue: initialValue, upperBound: defaultUpperBound),
    ],
    .volume_us: [
        FieldPreset("Volume", unitsSuffix: "floz", initialValue: initialValue, upperBound: defaultUpperBound),
        FieldPreset("Volume", unitsSuffix: "qt", initialValue: initialValue, upperBound: defaultUpperBound),
        FieldPreset("Volume", unitsSuffix: "gal", initialValue: initialValue, upperBound: defaultUpperBound),
    ],
    .length_metric: [
        FieldPreset("Length", unitsSuffix: "mm", initialValue: initialValue, upperBound: defaultUpperBound),
        FieldPreset("Length", unitsSuffix: "cm", initialValue: initialValue, upperBound: defaultUpperBound),
        FieldPreset("Length", unitsSuffix: "m", initialValue: initialValue, upperBound: defaultUpperBound),
        FieldPreset("Length", unitsSuffix: "km", initialValue: initialValue, upperBound: defaultUpperBound),
    ],
    .length_us: [
        FieldPreset("Length", unitsSuffix: "in", initialValue: initialValue, upperBound: defaultUpperBound),
        FieldPreset("Length", unitsSuffix: "ft", initialValue: initialValue, upperBound: defaultUpperBound),
        FieldPreset("Length", unitsSuffix: "yd", initialValue: initialValue, upperBound: defaultUpperBound),
        FieldPreset("Length", unitsSuffix: "mi", initialValue: initialValue, upperBound: defaultUpperBound),
    ],
    .temperature_metric: [
        FieldPreset("Temperature", unitsSuffix: "℃", initialValue: Int16(20), upperBound: Int16(100)), // °C
    ],
    .temperature_us: [
        FieldPreset("Temperature", unitsSuffix: "℉", initialValue: Int16(68), upperBound: Int16(212)), // °F
    ],
    .pressure_metric: [
        FieldPreset("Pressure", unitsSuffix: "bar", initialValue: Int16(0), upperBound: Int16(250)),
    ],
    .pressure_us: [
        FieldPreset("Pressure", unitsSuffix: "psi", initialValue: Int16(0), upperBound: Int16(3600)),
    ],
]
