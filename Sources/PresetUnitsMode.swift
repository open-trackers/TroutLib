//
//  PresetsUnitsMode.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public enum PresetsUnitsMode: Int, CaseIterable, CustomStringConvertible {
    case all = 0
    case metricOnly = 1
    case usOnly = 2

    public var description: String {
        switch self {
        case .all:
            return "All"
        case .metricOnly:
            return "Metric"
        case .usOnly:
            return "US"
        }
    }
}
