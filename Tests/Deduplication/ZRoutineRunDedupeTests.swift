//
//  ZRoutineRunDedupeTests.swift
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

final class ZRoutineRunDedupeTests: TestBase {
    let routineArchiveID1 = UUID()
    let routineArchiveID2 = UUID()
    let taskArchiveID1 = UUID()
    let taskArchiveID2 = UUID()

    let date1Str = "2023-01-02T21:00:00Z"
    var date1: Date!
    let date2Str = "2023-01-03T21:00:00Z"
    var date2: Date!
    let name1 = "blah1"
    let name2 = "blah2"
    let startedAt1Str = "2023-01-02T21:00:00Z"
    var startedAt1: Date!
    let startedAt2Str = "2023-01-03T21:00:00Z"
    var startedAt2: Date!
    let completedAt1Str = "2023-01-04T04:00:01Z"
    var completedAt1: Date!
    let completedAt2Str = "2023-01-04T04:00:02Z"
    var completedAt2: Date!

    override func setUpWithError() throws {
        try super.setUpWithError()

        date1 = df.date(from: date1Str)
        date2 = df.date(from: date2Str)
        startedAt1 = df.date(from: startedAt1Str)
        startedAt2 = df.date(from: startedAt2Str)
        completedAt1 = df.date(from: completedAt1Str)
        completedAt2 = df.date(from: completedAt2Str)
    }

    func testDifferentConsumedDay() throws {
        let c1 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: "blah", createdAt: date1, toStore: mainStore)
        let dr1 = ZRoutineRun.create(testContext, zRoutine: c1, startedAt: startedAt1, elapsedSecs: 10, createdAt: date1, toStore: mainStore)
        let dr2 = ZRoutineRun.create(testContext, zRoutine: c1, startedAt: startedAt2, elapsedSecs: 10, createdAt: date2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZRoutineRun.dedupe(testContext, routineArchiveID: routineArchiveID1, startedAt: startedAt1, inStore: mainStore)

        XCTAssertFalse(dr1.isDeleted)
        XCTAssertFalse(dr2.isDeleted)
    }

    func testSameConsumedDay() throws {
        let c1 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: "blah", createdAt: date1, toStore: mainStore)
        let dr1 = ZRoutineRun.create(testContext, zRoutine: c1, startedAt: startedAt1, elapsedSecs: 10, createdAt: date1, toStore: mainStore)
        let dr2 = ZRoutineRun.create(testContext, zRoutine: c1, startedAt: startedAt1, elapsedSecs: 10, createdAt: date2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZRoutineRun.dedupe(testContext, routineArchiveID: routineArchiveID1, startedAt: startedAt1, inStore: mainStore)

        XCTAssertFalse(dr1.isDeleted)
        XCTAssertTrue(dr2.isDeleted)
    }

    func testDupeConsolidateMTaskRuns() throws {
        let c1 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: "blah", createdAt: date1, toStore: mainStore)
        // same startedAt
        let dr1 = ZRoutineRun.create(testContext, zRoutine: c1, startedAt: startedAt1, elapsedSecs: 10, createdAt: date1, toStore: mainStore)
        let dr2 = ZRoutineRun.create(testContext, zRoutine: c1, startedAt: startedAt1, elapsedSecs: 10, createdAt: date2, toStore: mainStore)

//        let c1 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: name1, createdAt: date1, toStore: mainStore)
        let s1 = ZTask.create(testContext, zRoutine: c1, taskArchiveID: taskArchiveID1, taskName: name1, createdAt: date1, toStore: mainStore)
        let s2 = ZTask.create(testContext, zRoutine: c1, taskArchiveID: taskArchiveID2, taskName: name1, createdAt: date2, toStore: mainStore)

        // note: does not dedupe task runs; it only consolidates them
        let r1 = ZTaskRun.create(testContext, zRoutineRun: dr1, zTask: s1, completedAt: completedAt1, toStore: mainStore)
        let r2 = ZTaskRun.create(testContext, zRoutineRun: dr2, zTask: s2, completedAt: completedAt2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZRoutineRun.dedupe(testContext, routineArchiveID: routineArchiveID1, startedAt: startedAt1, inStore: mainStore)

        XCTAssertFalse(dr1.isDeleted)
        XCTAssertTrue(dr2.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertFalse(s2.isDeleted)
        XCTAssertFalse(r1.isDeleted)
        XCTAssertFalse(r2.isDeleted)

        XCTAssertEqual(1, s1.zTaskRuns?.count) // not touched
        XCTAssertEqual(1, s2.zTaskRuns?.count)

        XCTAssertEqual(2, dr1.zTaskRuns?.count) // consolidated
        XCTAssertEqual(0, dr2.zTaskRuns?.count)
    }
}
