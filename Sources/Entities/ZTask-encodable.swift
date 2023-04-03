//
//  ZTask-encodable.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension ZTask: Encodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case name
        // case units
        case taskArchiveID
        case createdAt
        case routineArchiveID // FK
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        // try c.encode(units, forKey: .units)
        try c.encode(taskArchiveID, forKey: .taskArchiveID)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(zRoutine?.routineArchiveID, forKey: .routineArchiveID)
    }
}

extension ZTask: MAttributable {
    public static var fileNamePrefix: String {
        "ztasks"
    }

    public static var attributes: [MAttribute] = [
        MAttribute(CodingKeys.name, .string),
        // MAttribute(CodingKeys.units, .int),
        MAttribute(CodingKeys.taskArchiveID, .string),
        MAttribute(CodingKeys.createdAt, .date),
        MAttribute(CodingKeys.routineArchiveID, .string),
    ]
}
