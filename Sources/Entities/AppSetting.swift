//
//  AppSetting.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension AppSetting {
    var presetUnitsModeEnum: PresetsUnitsMode {
        get { PresetsUnitsMode(rawValue: Int(presetUnitsMode)) ?? PresetsUnitsMode.all }
        set { presetUnitsMode = Int16(newValue.rawValue) }
    }
}

public extension AppSetting {
    // NOTE: does NOT save context
    static func create(_ context: NSManagedObjectContext,
                       createdAt: Date = Date.now) -> AppSetting
    {
        let nu = AppSetting(context: context)
        nu.createdAt = createdAt
        nu.presetUnitsModeEnum = .all
        return nu
    }
}
