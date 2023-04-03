//
//  ZTaskDedupeTests.swift
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

final class ZTaskDedupeTests: TestBase {
    let routineArchiveID1 = UUID()
    let routineArchiveID2 = UUID()
    let taskArchiveID1 = UUID()
    let taskArchiveID2 = UUID()

    let date1Str = "2023-01-02T21:00:01Z"
    var date1: Date!
    let date2Str = "2023-01-02T21:00:02Z"
    var date2: Date!
    let startedAt1Str = "2023-01-03T03:00:01Z"
    var startedAt1: Date!
    let completedAt1Str = "2023-01-04T04:00:01Z"
    var completedAt1: Date!
    let completedAt2Str = "2023-01-04T04:00:02Z"
    var completedAt2: Date!
    let name1 = "blah1"
    let name2 = "blah2"

    override func setUpWithError() throws {
        try super.setUpWithError()

        date1 = df.date(from: date1Str)
        date2 = df.date(from: date2Str)
        startedAt1 = df.date(from: startedAt1Str)
        completedAt1 = df.date(from: completedAt1Str)
        completedAt2 = df.date(from: completedAt2Str)
    }

    func testDifferentArchiveID() throws {
        let c1 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: "blah", createdAt: date1, toStore: mainStore)
        let s1 = ZTask.create(testContext, zRoutine: c1, taskArchiveID: taskArchiveID1, taskName: "bleh1", createdAt: date1, toStore: mainStore)
        let s2 = ZTask.create(testContext, zRoutine: c1, taskArchiveID: taskArchiveID2, taskName: "bleh2", createdAt: date2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZTask.dedupe(testContext, routineArchiveID: routineArchiveID1, taskArchiveID: taskArchiveID1, inStore: mainStore)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertFalse(s2.isDeleted)
    }

    func testSameArchiveIdWithinMRoutine() throws {
        let c1 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: "blah", createdAt: date1, toStore: mainStore)
        let s1 = ZTask.create(testContext, zRoutine: c1, taskArchiveID: taskArchiveID1, taskName: "bleh1", createdAt: date1, toStore: mainStore)
        let s2 = ZTask.create(testContext, zRoutine: c1, taskArchiveID: taskArchiveID1, taskName: "bleh2", createdAt: date2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZTask.dedupe(testContext, routineArchiveID: routineArchiveID1, taskArchiveID: taskArchiveID1, inStore: mainStore)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertTrue(s2.isDeleted)
    }

    func testSameArchiveIdOutsideMRoutine() throws {
        let c1 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: "blah1", createdAt: date1, toStore: mainStore)
        let c2 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID2, routineName: "blah2", createdAt: date2, toStore: mainStore)
        let s1 = ZTask.create(testContext, zRoutine: c1, taskArchiveID: taskArchiveID1, taskName: "bleh1", createdAt: date1, toStore: mainStore)
        let s2 = ZTask.create(testContext, zRoutine: c2, taskArchiveID: taskArchiveID1, taskName: "bleh2", createdAt: date2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZTask.dedupe(testContext, routineArchiveID: routineArchiveID1, taskArchiveID: taskArchiveID1, inStore: mainStore)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertFalse(c2.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertFalse(s2.isDeleted)
    }

    func testDupeConsolidateMTaskRuns() throws {
        let c1 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: name1, createdAt: date1, toStore: mainStore)

        // same taskArchiveID
        let s1 = ZTask.create(testContext, zRoutine: c1, taskArchiveID: taskArchiveID1, taskName: name1, createdAt: date1, toStore: mainStore)
        let s2 = ZTask.create(testContext, zRoutine: c1, taskArchiveID: taskArchiveID1, taskName: name1, createdAt: date2, toStore: mainStore)

        // note: does not dedupe task runs; it only consolidates them
        let dr = ZRoutineRun.create(testContext, zRoutine: c1, startedAt: startedAt1, toStore: mainStore)
        let r1 = ZTaskRun.create(testContext, zRoutineRun: dr, zTask: s1, completedAt: completedAt1, toStore: mainStore)
        let r2 = ZTaskRun.create(testContext, zRoutineRun: dr, zTask: s1, completedAt: completedAt2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZTask.dedupe(testContext, routineArchiveID: routineArchiveID1, taskArchiveID: taskArchiveID1, inStore: mainStore)

        XCTAssertFalse(s1.isDeleted)
        XCTAssertTrue(s2.isDeleted)
        XCTAssertFalse(r1.isDeleted)
        XCTAssertFalse(r2.isDeleted)

        XCTAssertEqual(2, s1.zTaskRuns?.count) // consolidated
        XCTAssertEqual(0, s2.zTaskRuns?.count)
    }
}
