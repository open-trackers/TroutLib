//
//  CleanLogRecordTests.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

@testable import TroutLib
import XCTest

final class CleanLogRecordTests: TestBase {
    func testMRoutineKeepAt() throws {
        let uuid = UUID()
        let startDate = Date.now
        let r = ZRoutine.create(testContext, routineArchiveID: uuid, routineName: "blah", toStore: mainStore)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startDate, elapsedSecs: 1, toStore: mainStore)
        try testContext.save()

        XCTAssertFalse(r.isDeleted)
        XCTAssertFalse(rr.isDeleted)
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: uuid))
        XCTAssertEqual(1, try ZRoutineRun.count(testContext))

        try cleanLogRecords(testContext, keepSince: startDate, inStore: mainStore)
        try testContext.save()

        XCTAssertFalse(r.isDeleted)
        XCTAssertFalse(rr.isDeleted)
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: uuid))
        XCTAssertEqual(1, try ZRoutineRun.count(testContext))
    }

    func testMRoutineDumpEarlierThan() throws {
        let uuid = UUID()
        let startDate = Date.now
        let r = ZRoutine.create(testContext, routineArchiveID: uuid, routineName: "blah", toStore: mainStore)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startDate, elapsedSecs: 1, toStore: mainStore)
        try testContext.save()

        XCTAssertFalse(r.isDeleted)
        XCTAssertFalse(rr.isDeleted)
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: uuid))
        XCTAssertEqual(1, try ZRoutineRun.count(testContext))

        try cleanLogRecords(testContext, keepSince: startDate.addingTimeInterval(1), inStore: mainStore)
        try testContext.save()

        XCTAssertEqual(0, try ZRoutineRun.count(testContext))

        // TODO: need to purge orphaned ZRoutines
        // XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: uuid))
    }

    func testMTaskKeepAt() throws {
        let rUUID = UUID()
        let eUUID = UUID()
        let startDate = Date.now
        let completeDate = startDate
        let r = ZRoutine.create(testContext, routineArchiveID: rUUID, routineName: "blah", toStore: mainStore)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startDate, elapsedSecs: 1, toStore: mainStore)
        let e = ZTask.create(testContext, zRoutine: r, taskArchiveID: eUUID, taskName: "blah", toStore: mainStore)
        let ee = ZTaskRun.create(testContext, zRoutineRun: rr, zTask: e, completedAt: completeDate, toStore: mainStore)
        try testContext.save()

        XCTAssertFalse(e.isDeleted)
        XCTAssertFalse(ee.isDeleted)
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: rUUID, taskArchiveID: eUUID))
        XCTAssertEqual(1, try ZTaskRun.count(testContext))

        try cleanLogRecords(testContext, keepSince: completeDate, inStore: mainStore)
        try testContext.save()

        XCTAssertFalse(e.isDeleted)
        XCTAssertFalse(ee.isDeleted)
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: rUUID, taskArchiveID: eUUID))
        XCTAssertEqual(1, try ZTaskRun.count(testContext))
    }

    func testMTaskDumpEarlierThan() throws {
        let rUUID = UUID()
        let eUUID = UUID()
        let startDate = Date.now
        let completeDate = startDate
        let r = ZRoutine.create(testContext, routineArchiveID: rUUID, routineName: "blah", toStore: mainStore)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: startDate, elapsedSecs: 1, toStore: mainStore)
        let e = ZTask.create(testContext, zRoutine: r, taskArchiveID: eUUID, taskName: "blah", toStore: mainStore)
        let ee = ZTaskRun.create(testContext, zRoutineRun: rr, zTask: e, completedAt: completeDate, toStore: mainStore)
        try testContext.save()

        XCTAssertFalse(e.isDeleted)
        XCTAssertFalse(ee.isDeleted)
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: rUUID, taskArchiveID: eUUID))
        XCTAssertEqual(1, try ZTaskRun.count(testContext))

        try cleanLogRecords(testContext, keepSince: completeDate.addingTimeInterval(1), inStore: mainStore)
        try testContext.save()

        XCTAssertEqual(0, try ZTaskRun.count(testContext))

        // TODO: need to purge orphaned ZTasks
        // XCTAssertNil(try ZTask.get(testContext, taskArchiveID: eUUID))
    }
}
