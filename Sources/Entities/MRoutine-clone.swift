//
//  MRoutine-clone.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension MRoutine {
    // deep copy the routine and its tasks
    // NOTE: does NOT save context
    func clone(_ context: NSManagedObjectContext, now: Date = Date.now) throws -> MRoutine {
        guard isTemplate else { throw TrackerError.invalidAction(msg: "Can only clone from template.") }

        let clUserOrder = try (MRoutine.maxUserOrder(context) ?? 0) + 1

        let nuName = try (Self.getUniqueRoutineName(context, wrappedName)) ?? "\(wrappedName) 1"

        let nuRoutine = MRoutine.create(context, userOrder: clUserOrder, name: nuName, createdAt: now)
        nuRoutine.imageName = imageName
        nuRoutine.color = color

        let pred = MTask.getPredicate(routine: self)
        try context.fetcher(predicate: pred) { (element: MTask) in
            let nuTask = MTask.create(context, routine: nuRoutine, userOrder: element.userOrder, createdAt: now)
            nuTask.name = element.name

            let fieldPred = MField.getPredicate(task: element)
            try context.fetcher(predicate: fieldPred) { (element: MField) in
                if let _element = element as? MFieldBool {
                    let field = MFieldBool.create(context,
                                                  task: nuTask,
                                                  name: element.name ?? "",
                                                  userOrder: element.userOrder,
                                                  clearOnRun: element.clearOnRun,
                                                  createdAt: now,
                                                  value: _element.value)
                    field.unitsSuffix = element.unitsSuffix
                } else if let _element = element as? MFieldInt16 {
                    let field = MFieldInt16.create(context,
                                                   task: nuTask,
                                                   name: element.name ?? "",
                                                   userOrder: element.userOrder,
                                                   clearOnRun: element.clearOnRun,
                                                   createdAt: now,
                                                   defaultValue: _element.defaultValue,
                                                   value: _element.value,
                                                   upperBound: _element.upperBound,
                                                   stepValue: _element.stepValue)
                    field.unitsSuffix = element.unitsSuffix
                }
                return true
            }
            return true
        }

        // save lastStartedAt to indicate last clone time for SinceText in RoutineCell
        lastStartedAt = now
        lastDuration = 0

        return nuRoutine
    }

    // Try to go from "Foo" to "Foo 1", or "Bar 135" to "Bar 136"
    internal static func getUniqueRoutineName(_ context: NSManagedObjectContext, _ origName: String) throws -> String? {
        let pattern = #/^(.*?)(\d*)\s*$/#

        guard let result = origName.firstMatch(of: pattern)
        else { return nil }

        let rawPrefix = String(result.1)
        let rawSuffix = String(result.2)

        let normPrefix = rawPrefix.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var maxSuffix = max(0, Int(rawSuffix) ?? 0)

        try context.fetcher { (element: MRoutine) in
            guard let result = element.wrappedName.firstMatch(of: pattern) else { return true } // continue

            let prefix = String(result.1).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard prefix == normPrefix else { return true } // continue
            let su = Int(result.2) ?? 0
            if su > maxSuffix { maxSuffix = su }
            return true // continue
        }

        let trimmedPrefix = rawPrefix.trimmingCharacters(in: .whitespacesAndNewlines)

        return trimmedPrefix.count > 0 ? "\(trimmedPrefix) \(maxSuffix + 1)" : "\(maxSuffix + 1)"
    }
}
