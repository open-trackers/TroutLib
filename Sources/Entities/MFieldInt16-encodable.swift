//
//  MFieldInt16-encodable.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension MFieldInt16: Encodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case archiveID
        case controlType
        case createdAt
        case fieldType
        case name
        case unitsSuffix
        case clearOnRun
        case userOrder
        case stepValue
        case upperBound
        case defaultValue
        case value
        case taskArchiveID // FK
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(archiveID, forKey: .archiveID)
        try c.encode(controlType, forKey: .controlType)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(fieldType, forKey: .fieldType)
        try c.encode(name, forKey: .name)
        try c.encode(unitsSuffix, forKey: .unitsSuffix)
        try c.encode(clearOnRun, forKey: .clearOnRun)
        try c.encode(userOrder, forKey: .userOrder)
        try c.encode(stepValue, forKey: .stepValue)
        try c.encode(upperBound, forKey: .upperBound)
        try c.encode(defaultValue, forKey: .defaultValue)
        try c.encode(value, forKey: .value)
        try c.encode(task?.archiveID, forKey: .taskArchiveID)
    }
}

extension MFieldInt16: MAttributable {
    public static var fileNamePrefix: String {
        "int16fields"
    }

    public static var attributes: [MAttribute] = [
        MAttribute(CodingKeys.archiveID, .string),
        MAttribute(CodingKeys.controlType, .int),
        MAttribute(CodingKeys.createdAt, .date),
        MAttribute(CodingKeys.fieldType, .int),
        MAttribute(CodingKeys.name, .string),
        MAttribute(CodingKeys.unitsSuffix, .string),
        MAttribute(CodingKeys.clearOnRun, .bool),
        MAttribute(CodingKeys.userOrder, .int),
        MAttribute(CodingKeys.stepValue, .int),
        MAttribute(CodingKeys.upperBound, .int),
        MAttribute(CodingKeys.defaultValue, .int),
        MAttribute(CodingKeys.value, .int),
        MAttribute(CodingKeys.taskArchiveID, .string),
    ]
}
