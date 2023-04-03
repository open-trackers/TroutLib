//
//  FieldGroupBool.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// us identifiers, to use for filtering presets to those relevant to a task
public enum FieldGroupBool: Int, CaseIterable, CustomStringConvertible {
    case progress = 1
    case journey = 2
    case power = 3
    case location = 4
    case status = 5

    public var description: String {
        switch self {
        case .progress:
            return "Progress"
        case .journey:
            return "Journey"
        case .power:
            return "Power"
        case .location:
            return "Location"
        case .status:
            return "Status"
        }
    }
}

extension FieldGroupBool: Comparable {
    public static func < (lhs: FieldGroupBool, rhs: FieldGroupBool) -> Bool {
        lhs.description < rhs.description
    }
}
