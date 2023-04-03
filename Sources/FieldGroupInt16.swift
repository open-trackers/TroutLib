//
//  FieldGroupInt16.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// us identifiers, to use for filtering presets to those relevant to a task
public enum FieldGroupInt16: Int, CaseIterable, CustomStringConvertible {
    case quantity = 1
    case weight_metric = 2
    case weight_us = 3
    case volume_metric = 4
    case volume_us = 5
    case length_metric = 6
    case length_us = 7
    case temperature_metric = 8
    case temperature_us = 9
    case pressure_metric = 10
    case pressure_us = 11

    public var description: String {
        switch self {
        case .quantity:
            return "Quantity"
        case .weight_metric:
            return "Weight (metric)"
        case .volume_metric:
            return "Volume (metric)"
        case .length_metric:
            return "Length (metric)"
        case .temperature_metric:
            return "Temperature (metric)"
        case .weight_us:
            return "Weight (us)"
        case .volume_us:
            return "Volume (us)"
        case .length_us:
            return "Length (us)"
        case .temperature_us:
            return "Temperature (us)"
        case .pressure_metric:
            return "Pressure (metric)"
        case .pressure_us:
            return "Pressure (us)"
        }
    }

    public static let metricGroups: [FieldGroupInt16] =
        [
            .weight_metric,
            .volume_metric,
            .length_metric,
            .temperature_metric,
            .pressure_metric,
        ]

    public static let usGroups: [FieldGroupInt16] =
        [
            .weight_us,
            .volume_us,
            .length_us,
            .temperature_us,
            .pressure_us,
        ]
}

extension FieldGroupInt16: Comparable {
    public static func < (lhs: FieldGroupInt16, rhs: FieldGroupInt16) -> Bool {
        lhs.description < rhs.description
    }
}
