//
//  RoutinePreset.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import TextFieldPreset

import TrackerLib

public struct RoutinePreset: PresettableItem, CustomStringConvertible {
    public var text: String
    public let taskGroups: [TaskGroup]

    public init(_ text: String, _ taskGroups: [TaskGroup] = []) {
        self.text = text
        self.taskGroups = taskGroups
    }

    public var description: String {
        "\(text)"
    }
}
