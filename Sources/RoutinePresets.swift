//
//  RoutinePresets.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Collections
import Foundation

public typealias RoutinePresetDict = OrderedDictionary<String, [RoutinePreset]>

// see README for guidelines on adding/maintaining these presets.
// List a set of TaskGroups for each top-level category (e.g., "Travel")
// When user selects one of these presets, assign the specified MTaskGroup(s) to their routine.
// This will determine which tasks are visible when creating new tasks in their routine.
public let routinePresets: RoutinePresetDict = [
    "Travel Packing": [
        RoutinePreset("General", [.travelDocumentation, .travelToiletries, .travelClothing, .travelAccessories]),
        RoutinePreset("Cold Weather", [.travelDocumentation, .travelToiletries, .travelClothing, .travelAccessories, .coldWeatherTravel]),
        RoutinePreset("Tropical", [.travelDocumentation, .travelToiletries, .travelClothing, .travelAccessories, .warmWeatherTravel]),
        RoutinePreset("Business", [.travelDocumentation, .travelToiletries, .travelClothing, .travelAccessories, .businessTravel]),
        RoutinePreset("Diving", [.travelDocumentation, .travelToiletries, .travelClothing, .travelAccessories, .warmWeatherTravel, .diveTravel]),
    ],
    "Auto Inspection": [
        RoutinePreset("General (ICE)", [.autoInspection, .iceAutoInspection]),
    ],
    "Bike Inspection": [
        RoutinePreset("General", [.bikeInspection]),
        RoutinePreset("E-Bike", [.bikeInspection, .ebikeInspection]),
    ],
]
