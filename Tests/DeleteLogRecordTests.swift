//
//  DeleteLogRecordTests.swift
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

final class DeleteLogRecordTests: TestBase {
    let routineArchiveID = UUID()
    let taskArchiveID = UUID()
    let fieldArchiveID = UUID()

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    func testZRoutineRunFromBothStores() throws {
        let startedAt = Date.now
        let r = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        _ = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startedAt, elapsedSecs: 1, toStore: mainStore)
        // try testContext.save()
        _ = try deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))

        try ZRoutineRun.userRemove(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: nil)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        let a = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore)
        XCTAssertTrue(a!.userRemoved)
        let b = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore)
        XCTAssertTrue(b!.userRemoved)
    }

    func testZTaskRunFromBothStores() throws {
        let startedAt = Date.now
        let completedAt = startedAt + 1000
        let r = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startedAt, elapsedSecs: 1, toStore: mainStore)
        let e = ZTask.create(testContext, zRoutine: r, taskArchiveID: taskArchiveID, taskName: "bleh", toStore: mainStore)
        let tr = ZTaskRun.create(testContext, zRoutineRun: rr, zTask: e, completedAt: completedAt, toStore: mainStore)
        let sf = ZField.create(testContext, zTask: e, fieldArchiveID: fieldArchiveID, fieldName: "blort", toStore: mainStore)
        let sfr = ZFieldRun.create(testContext, zTaskRun: tr, zField: sf, toStore: mainStore)
        sfr.value = "2343"

        _ = try deepCopy(testContext, fromStore: mainStore, toStore: archiveStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID, completedAt: completedAt, inStore: mainStore))
        XCTAssertNotNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID, completedAt: completedAt, inStore: archiveStore))
        XCTAssertNotNil(try ZFieldRun.get(testContext, fieldArchiveID: fieldArchiveID, completedAt: completedAt, inStore: mainStore))
        XCTAssertNotNil(try ZFieldRun.get(testContext, fieldArchiveID: fieldArchiveID, completedAt: completedAt, inStore: archiveStore))

        try ZTaskRun.userRemove(testContext, taskArchiveID: taskArchiveID, completedAt: completedAt, inStore: nil)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: archiveStore))
        let a = try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID, completedAt: completedAt, inStore: mainStore)
        XCTAssertTrue(a!.userRemoved)
        let b = try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID, completedAt: completedAt, inStore: archiveStore)
        XCTAssertTrue(b!.userRemoved)

        let c = try ZFieldRun.get(testContext, fieldArchiveID: fieldArchiveID, completedAt: completedAt, inStore: mainStore)
        XCTAssertTrue(c!.userRemoved)
        let d = try ZFieldRun.get(testContext, fieldArchiveID: fieldArchiveID, completedAt: completedAt, inStore: archiveStore)
        XCTAssertTrue(d!.userRemoved)
    }
}
