//
//  MField.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

@objc(MField)
public class MField: NSManagedObject {}

public extension MField {
    enum FieldType: Int16, CaseIterable {
        case bool = 1
        case int16 = 2
    }

    enum ControlType: Int16, CaseIterable {
        case `default` = 0
        case stepper = 1
        case numPad = 2
    }

    internal func create(fieldType: FieldType,
                         controlType: ControlType,
                         task: MTask,
                         name: String,
                         userOrder: Int16,
                         unitsSuffix: String?,
                         clearOnRun: Bool,
                         archiveID: UUID,
                         createdAt: Date)
    {
        self.fieldType = fieldType.rawValue
        self.controlType = controlType.rawValue
        self.task = task
        self.name = name
        self.userOrder = userOrder
        self.unitsSuffix = unitsSuffix
        self.clearOnRun = clearOnRun
        self.archiveID = archiveID
        self.createdAt = createdAt
    }

    var wrappedName: String {
        get { name ?? "unknown" }
        set { name = newValue }
    }

    var wrappedUnitsSuffix: String {
        get { unitsSuffix ?? "" }
        set { unitsSuffix = newValue }
    }

    @objc func valueAsString() -> String {
        ""
    }
}
