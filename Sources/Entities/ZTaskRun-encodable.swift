//
//  ZTaskRun.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

extension ZTaskRun: Encodable {
    private enum CodingKeys: String, CodingKey, CaseIterable {
        case completedAt
//        case intensity
        case createdAt
        case userRemoved
        case taskArchiveID // FK
        case routineRunStartedAt // FK
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(completedAt, forKey: .completedAt)
//        try c.encode(intensity, forKey: .intensity)
        try c.encode(userRemoved, forKey: .userRemoved)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(zTask?.taskArchiveID, forKey: .taskArchiveID)
        try c.encode(zRoutineRun?.startedAt, forKey: .routineRunStartedAt)
    }
}

extension ZTaskRun: MAttributable {
    public static var fileNamePrefix: String {
        "ztaskruns"
    }

    public static var attributes: [MAttribute] = [
        MAttribute(CodingKeys.completedAt, .date),
//        MAttribute(CodingKeys.intensity, .double),
        MAttribute(CodingKeys.userRemoved, .bool),
        MAttribute(CodingKeys.createdAt, .date),
        MAttribute(CodingKeys.taskArchiveID, .string),
        MAttribute(CodingKeys.routineRunStartedAt, .date),
    ]
}
