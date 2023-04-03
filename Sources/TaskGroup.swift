//
//  TaskGroup.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// standard identifiers, to use for filtering presets to those relevant to a routine
public enum TaskGroup: Int16, CaseIterable, CustomStringConvertible {
    case coldWeatherTravel = 1 // jacket, hat, mittens
    case warmWeatherTravel = 2 // sunscreen, hat, swimwear
    case diveTravel = 3 // bc, regulator, computer
    case businessTravel = 4 // dress shirts
    case travelToiletries = 5
    case travelDocumentation = 6
    case travelClothing = 7
    case travelAccessories = 8
    case autoInspection = 100
    case iceAutoInspection = 101
    case bikeInspection = 200
    case ebikeInspection = 201

    public var description: String {
        switch self {
        case .coldWeatherTravel:
            return "Cold Weather Travel"
        case .warmWeatherTravel:
            return "Tropical Travel"
        case .diveTravel:
            return "Dive Travel"
        case .businessTravel:
            return "Business Travel"
        case .travelToiletries:
            return "Travel Toiletries"
        case .travelDocumentation:
            return "Travel Documentation"
        case .travelClothing:
            return "Travel Clothing"
        case .travelAccessories:
            return "Travel Accessories"
        case .autoInspection:
            return "Auto Inspection"
        case .iceAutoInspection:
            return "ICE Auto Inspection"
        case .bikeInspection:
            return "Bike Inspection"
        case .ebikeInspection:
            return "E-Bike Inspection"
        }
    }
}

extension TaskGroup: Comparable {
    public static func < (lhs: TaskGroup, rhs: TaskGroup) -> Bool {
        lhs.description < rhs.description
    }
}
