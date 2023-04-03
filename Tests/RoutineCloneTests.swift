//
//  RoutineCloneTests.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

@testable import TroutLib
import XCTest

import Foundation

final class RoutineCloneTests: TestBase {
    let routineArchiveID = UUID()
    let taskArchiveID = UUID()
    let fieldArchiveID1 = UUID()
    let fieldArchiveID2 = UUID()
    let now = Date.now
    let earlier = Date.now.addingTimeInterval(-1000)

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    // NOTE: lastStartedAt is used to display the "last cloned " in Routine cell
    func testEnsureStartedAtSetToTimeOfClone() throws {
        let sRoutine = MRoutine.create(testContext, userOrder: 5, name: "blink")
        sRoutine.isTemplate = true
        try testContext.save()

        _ = try sRoutine.clone(testContext, now: now)
        try testContext.save()

        XCTAssertEqual(now, sRoutine.lastStartedAt)
    }

    func testCannotCloneNonTemplate() throws {
        let sRoutine = MRoutine.create(testContext, userOrder: 5, name: "blink", archiveID: routineArchiveID, createdAt: earlier)
        sRoutine.isTemplate = false
        try testContext.save()
        XCTAssertThrowsError(try sRoutine.clone(testContext, now: now)) { error in
            XCTAssertEqual(TrackerError.invalidAction(msg: "Can only clone from template."), error as! TrackerError)
        }
    }

    func testRoutineWithOneTaskAndFields() throws {
        let colorStr = "red".data(using: .utf8)
        let sRoutine = MRoutine.create(testContext, userOrder: 5, name: "blink 0", archiveID: routineArchiveID, createdAt: earlier)
        sRoutine.isTemplate = true
        sRoutine.color = colorStr
        sRoutine.imageName = "blort"
        sRoutine.lastDuration = 3543
        sRoutine.lastStartedAt = earlier
        let sTask = MTask.create(testContext, routine: sRoutine, userOrder: 18, name: "bleh", archiveID: taskArchiveID, createdAt: earlier)
        sTask.lastCompletedAt = earlier
        let sBoolField = MFieldBool.create(testContext, task: sTask, name: "foo", userOrder: 1, archiveID: fieldArchiveID1, createdAt: earlier, value: true)
        sBoolField.unitsSuffix = "kg"
        sBoolField.clearOnRun = false
        let sInt16Field = MFieldInt16.create(testContext, task: sTask, name: "bar", userOrder: 2, archiveID: fieldArchiveID2, createdAt: earlier, value: 353, upperBound: 500, stepValue: 12)
        sInt16Field.unitsSuffix = "lb"
        sInt16Field.clearOnRun = true
        sInt16Field.defaultValue = 2334
        try testContext.save()

        let cRoutine = try sRoutine.clone(testContext, now: now)
        try testContext.save()

        // ensure source records still there
        XCTAssertNotNil(try MRoutine.get(testContext, archiveID: routineArchiveID))
        XCTAssertNotNil(try MTask.get(testContext, routineArchiveID: routineArchiveID, archiveID: taskArchiveID))
        XCTAssertNotNil(try MField.get(testContext, taskArchiveID: taskArchiveID, archiveID: fieldArchiveID1))
        XCTAssertNotNil(try MField.get(testContext, taskArchiveID: taskArchiveID, archiveID: fieldArchiveID2))

        XCTAssertNotNil(cRoutine)
        XCTAssertNotEqual(routineArchiveID, cRoutine.archiveID)
        XCTAssertFalse(cRoutine.isTemplate)
        XCTAssertEqual(0, cRoutine.lastDuration)
        XCTAssertEqual("blort", cRoutine.imageName)
        XCTAssertEqual(colorStr, sRoutine.color)
        XCTAssertNil(cRoutine.lastStartedAt)
        XCTAssertNotEqual(sRoutine.name, cRoutine.name)
        XCTAssertNotEqual(sRoutine.userOrder, cRoutine.userOrder)
        XCTAssertTrue(sRoutine.userOrder < cRoutine.userOrder)
        XCTAssertEqual("blink 1", cRoutine.wrappedName)
        XCTAssertEqual(now, cRoutine.createdAt)

        let cTask = cRoutine.tasksArray.first
        XCTAssertNotNil(cTask)

        XCTAssertEqual(sTask.name, cTask?.name)
        XCTAssertNotEqual(taskArchiveID, cTask?.archiveID)
        XCTAssertEqual(sTask.userOrder, cTask?.userOrder)
        XCTAssertNil(cTask?.lastCompletedAt)
        XCTAssertEqual(now, cTask?.createdAt)

        guard let f1 = cTask?.fieldsArray.first(where: { $0.name == "foo" }),
              let cBoolField = f1 as? MFieldBool
        else { XCTFail(); return }

        XCTAssertNotEqual(fieldArchiveID1, cBoolField.archiveID)
        XCTAssertEqual(sBoolField.userOrder, cBoolField.userOrder)
        XCTAssertEqual(sBoolField.fieldType, cBoolField.fieldType)
        XCTAssertEqual(sBoolField.controlType, cBoolField.controlType)
        XCTAssertEqual(sBoolField.unitsSuffix, cBoolField.unitsSuffix)
        XCTAssertEqual(sBoolField.name, cBoolField.name)
        XCTAssertTrue(cBoolField.value)
        XCTAssertFalse(cBoolField.clearOnRun)
        XCTAssertEqual(now, cBoolField.createdAt)

        guard let f2 = cTask?.fieldsArray.first(where: { $0.name == "bar" }),
              let cInt16Field = f2 as? MFieldInt16
        else { XCTFail(); return }

        XCTAssertNotEqual(fieldArchiveID1, cInt16Field.archiveID)
        XCTAssertEqual(sInt16Field.userOrder, cInt16Field.userOrder)
        XCTAssertEqual(sInt16Field.fieldType, cInt16Field.fieldType)
        XCTAssertEqual(sInt16Field.controlType, cInt16Field.controlType)
        XCTAssertEqual(sInt16Field.unitsSuffix, sInt16Field.unitsSuffix)
        XCTAssertEqual(sInt16Field.name, cInt16Field.name)
        XCTAssertEqual(sInt16Field.value, cInt16Field.value)
        XCTAssertEqual(sInt16Field.upperBound, cInt16Field.upperBound)
        XCTAssertEqual(sInt16Field.stepValue, cInt16Field.stepValue)
        XCTAssertEqual(sInt16Field.defaultValue, cInt16Field.defaultValue)
        XCTAssertEqual(sInt16Field.clearOnRun, cInt16Field.clearOnRun)
        XCTAssertEqual(now, cInt16Field.createdAt)
    }

    func testRoutineWithNumSuffix() throws {
        let name = "blink X   181   "
        let sRoutine = MRoutine.create(testContext, userOrder: 5, name: name)
        sRoutine.isTemplate = true
        try testContext.save()

        let cRoutine = try sRoutine.clone(testContext, now: now)
        try testContext.save()

        XCTAssertEqual("blink X 182", cRoutine.wrappedName)
    }

    func testRoutineWithNoNumSuffix() throws {
        let name = "blink 181X"
        let sRoutine = MRoutine.create(testContext, userOrder: 5, name: name)
        sRoutine.isTemplate = true
        try testContext.save()

        let cRoutine = try sRoutine.clone(testContext, now: now)
        try testContext.save()

        XCTAssertEqual("\(name) 1", cRoutine.wrappedName)
    }

    func testGetUniqueName() throws {
        let origName = "blink X 181   "
        let sRoutine = MRoutine.create(testContext, userOrder: 0, name: origName)
        sRoutine.isTemplate = true
        _ = MRoutine.create(testContext, userOrder: 1, name: "blink X 182")
        _ = MRoutine.create(testContext, userOrder: 2, name: "blink X      183  ")
        _ = MRoutine.create(testContext, userOrder: 3, name: "blink 184 X ")
        try testContext.save()

        XCTAssertEqual("blink X 184", try MRoutine.getUniqueRoutineName(testContext, origName))
    }

    func testGetUniqueNameZero() throws {
        let origName = "0"
        let sRoutine = MRoutine.create(testContext, userOrder: 0, name: origName)
        sRoutine.isTemplate = true
        _ = MRoutine.create(testContext, userOrder: 1, name: "blink X 182")
        _ = MRoutine.create(testContext, userOrder: 2, name: "blink X      183  ")
        _ = MRoutine.create(testContext, userOrder: 3, name: "blink 184 X ")
        try testContext.save()

        XCTAssertEqual("1", try MRoutine.getUniqueRoutineName(testContext, origName))
    }

    func testGetUniqueNameOne() throws {
        let origName = "  1   1"
        let sRoutine = MRoutine.create(testContext, userOrder: 0, name: origName)
        sRoutine.isTemplate = true
        _ = MRoutine.create(testContext, userOrder: 1, name: "    ")
        _ = MRoutine.create(testContext, userOrder: 2, name: " 00  ")
        _ = MRoutine.create(testContext, userOrder: 3, name: " 1 ")
        _ = MRoutine.create(testContext, userOrder: 3, name: " 1 00 ")
        try testContext.save()

        XCTAssertEqual("1 2", try MRoutine.getUniqueRoutineName(testContext, origName))
    }

    func testGetUniqueNameBlank() throws {
        let origName = ""
        let sRoutine = MRoutine.create(testContext, userOrder: 0, name: origName)
        sRoutine.isTemplate = true
        _ = MRoutine.create(testContext, userOrder: 1, name: "    ")
        _ = MRoutine.create(testContext, userOrder: 2, name: " 00  ")
        _ = MRoutine.create(testContext, userOrder: 3, name: " 1 ")
        _ = MRoutine.create(testContext, userOrder: 3, name: " 1 00 ")
        try testContext.save()

        XCTAssertEqual("2", try MRoutine.getUniqueRoutineName(testContext, origName))
    }

    func testGetUniqueNameLettersOnly() throws {
        let origName = "ABC"
        let sRoutine = MRoutine.create(testContext, userOrder: 0, name: origName)
        sRoutine.isTemplate = true
        _ = MRoutine.create(testContext, userOrder: 1, name: "ABC1")
        _ = MRoutine.create(testContext, userOrder: 2, name: "ABC  2")
        _ = MRoutine.create(testContext, userOrder: 3, name: "ABC 3")
        _ = MRoutine.create(testContext, userOrder: 3, name: "ABC 4")
        try testContext.save()

        XCTAssertEqual("ABC 5", try MRoutine.getUniqueRoutineName(testContext, origName))
    }
}
