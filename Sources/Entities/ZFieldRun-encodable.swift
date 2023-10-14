//
//  ZFieldRun-encodable.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension ZFieldRun: Encodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case value
        case createdAt
        case userRemoved
        case fieldArchiveID // FK
        case taskRunCompletedAt // FK
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(value, forKey: .value)
        try c.encode(userRemoved, forKey: .userRemoved)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(zField?.fieldArchiveID, forKey: .fieldArchiveID)
        try c.encode(zTaskRun?.completedAt, forKey: .taskRunCompletedAt)
    }
}

extension ZFieldRun: MAttributable {
    public static var fileNamePrefix: String {
        "zfieldruns"
    }

    public static var attributes: [MAttribute] = [
        MAttribute(CodingKeys.value, .string),
        MAttribute(CodingKeys.userRemoved, .bool),
        MAttribute(CodingKeys.createdAt, .date),
        MAttribute(CodingKeys.fieldArchiveID, .string),
        MAttribute(CodingKeys.taskRunCompletedAt, .date),
    ]
}
