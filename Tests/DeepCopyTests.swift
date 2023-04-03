//
//  DeepCopyTests.swift
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

final class DeepCopyTests: TestBase {
    let routineArchiveID = UUID()
    let taskArchiveID = UUID()
    let fieldArchiveID = UUID()

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    func testRoutine() throws {
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))

        let sZRoutines = try deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertEqual([sr], sZRoutines)

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
    }

    func testRoutineWithRoutineRun() throws {
        let startedAt = Date()
        let elapsedSecs: TimeInterval = 30.0
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        _ = ZRoutineRun.create(testContext, zRoutine: sr, startedAt: startedAt, elapsedSecs: elapsedSecs, toStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))

        let sZRoutines = try deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertEqual([sr], sZRoutines)

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
    }

    func testRoutineWithTaskAndField() throws {
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let se = ZTask.create(testContext, zRoutine: sr, taskArchiveID: taskArchiveID, taskName: "bleh", toStore: mainStore)
        let sf = ZField.create(testContext, zTask: se, fieldArchiveID: fieldArchiveID, toStore: mainStore)
        sf.name = "blort"
        sf.unitsSuffix = "kg"
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZField.get(testContext, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: mainStore))

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZField.get(testContext, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: archiveStore))

        let sZRoutines = try deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertEqual([sr], sZRoutines)

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZField.get(testContext, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZField.get(testContext, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: archiveStore))
    }

    func testRoutineWithTaskAndTaskRunAndFieldRun() throws {
        let completedAt = Date()
        let startedAt = Date()
        let elapsedSecs: TimeInterval = 30.0
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let se = ZTask.create(testContext, zRoutine: sr, taskArchiveID: taskArchiveID, taskName: "bleh", toStore: mainStore)
        let srr = ZRoutineRun.create(testContext, zRoutine: sr, startedAt: startedAt, elapsedSecs: elapsedSecs, toStore: mainStore)
        let ser = ZTaskRun.create(testContext, zRoutineRun: srr, zTask: se, completedAt: completedAt, toStore: mainStore)
        let sf = ZField.create(testContext, zTask: se, fieldArchiveID: fieldArchiveID, fieldName: "blort", toStore: mainStore)
        let sfr = ZFieldRun.create(testContext, zTaskRun: ser, zField: sf, toStore: mainStore)
        sfr.value = "2343"
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID, completedAt: completedAt, inStore: mainStore))
        XCTAssertNotNil(try ZField.get(testContext, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZFieldRun.get(testContext, fieldArchiveID: fieldArchiveID, completedAt: completedAt, inStore: mainStore))

        let sZRoutines = try deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertEqual([sr], sZRoutines)

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID, completedAt: completedAt, inStore: mainStore))
        XCTAssertNotNil(try ZField.get(testContext, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZFieldRun.get(testContext, fieldArchiveID: fieldArchiveID, completedAt: completedAt, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID, completedAt: completedAt, inStore: archiveStore))
        XCTAssertNotNil(try ZField.get(testContext, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZFieldRun.get(testContext, fieldArchiveID: fieldArchiveID, completedAt: completedAt, inStore: archiveStore))
    }
}
