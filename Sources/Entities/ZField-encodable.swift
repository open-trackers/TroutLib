//
//  ZField-encodable.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension ZField: Encodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case name
        case unitsSuffix
        case fieldArchiveID
        case createdAt
        case taskArchiveID // FK
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(unitsSuffix, forKey: .unitsSuffix)
        try c.encode(fieldArchiveID, forKey: .fieldArchiveID)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(zTask?.taskArchiveID, forKey: .taskArchiveID)
    }
}

extension ZField: MAttributable {
    public static var fileNamePrefix: String {
        "zfields"
    }

    public static var attributes: [MAttribute] = [
        MAttribute(CodingKeys.name, .string),
        MAttribute(CodingKeys.unitsSuffix, .string),
        MAttribute(CodingKeys.fieldArchiveID, .string),
        MAttribute(CodingKeys.createdAt, .date),
        MAttribute(CodingKeys.taskArchiveID, .string),
    ]
}
