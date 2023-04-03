//
//  TaskPreset.swift
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

public struct TaskPreset: PresettableItem, CustomStringConvertible {
    public var text: String
    public let fields: [FieldPreset<AnyHashable>]

    public init(_ text: String, _ fields: [FieldPreset<AnyHashable>] = []) {
        self.text = text
        self.fields = fields
    }

    public var description: String {
        "\(text)"
    }
}
