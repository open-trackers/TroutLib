//
//  FieldPreset.swift
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

public struct FieldPreset<T>: PresettableItem, CustomStringConvertible
    where T: Equatable & Hashable
{
    public var text: String
    public let unitsSuffix: String?
    public let initialValue: T
    public let stepValue: T?
    public let upperBound: T?

    // TODO: optional lowerBound for Int/Float/Decimal/etc.?

    public init(_ text: String,
                unitsSuffix: String? = nil,
                initialValue: T,
                stepValue: T? = nil,
                upperBound: T? = nil)
    {
        self.text = text
        self.unitsSuffix = unitsSuffix
        self.initialValue = initialValue
        self.stepValue = stepValue
        self.upperBound = upperBound
    }

    public var description: String {
        if let unitsSuffix {
            return "\(text) (\(unitsSuffix))"
        } else {
            return text
        }
    }
}
