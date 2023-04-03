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

final class ZFieldDedupeTests: TestBase {
    let routineArchiveID1 = UUID()
    let routineArchiveID2 = UUID()
    let taskArchiveID1 = UUID()
    let taskArchiveID2 = UUID()
    let fieldArchiveID1 = UUID()
    let fieldArchiveID2 = UUID()

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
        let f1 = ZField.create(testContext, zTask: s1, fieldArchiveID: fieldArchiveID1, createdAt: date1, toStore: mainStore)
        let f2 = ZField.create(testContext, zTask: s1, fieldArchiveID: fieldArchiveID2, createdAt: date2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZField.dedupe(testContext, taskArchiveID: taskArchiveID1, fieldArchiveID: fieldArchiveID1, inStore: mainStore)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertFalse(f1.isDeleted)
        XCTAssertFalse(f2.isDeleted)
    }

    func testSameArchiveIdWithinMTask() throws {
        let c1 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: "blah", createdAt: date1, toStore: mainStore)
        let s1 = ZTask.create(testContext, zRoutine: c1, taskArchiveID: taskArchiveID1, taskName: "bleh1", createdAt: date1, toStore: mainStore)
        let f1 = ZField.create(testContext, zTask: s1, fieldArchiveID: fieldArchiveID1, createdAt: date1, toStore: mainStore)
        let f2 = ZField.create(testContext, zTask: s1, fieldArchiveID: fieldArchiveID1, createdAt: date2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZField.dedupe(testContext, taskArchiveID: taskArchiveID1, fieldArchiveID: fieldArchiveID1, inStore: mainStore)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertFalse(f1.isDeleted)
        XCTAssertTrue(f2.isDeleted)
    }

    func testSameArchiveIdOutsideMTask() throws {
        let c1 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: "blah1", createdAt: date1, toStore: mainStore)
        let s1 = ZTask.create(testContext, zRoutine: c1, taskArchiveID: taskArchiveID1, taskName: "bleh1", createdAt: date1, toStore: mainStore)
        let s2 = ZTask.create(testContext, zRoutine: c1, taskArchiveID: taskArchiveID2, taskName: "bleh2", createdAt: date2, toStore: mainStore)
        let f1 = ZField.create(testContext, zTask: s1, fieldArchiveID: fieldArchiveID1, createdAt: date1, toStore: mainStore)
        let f2 = ZField.create(testContext, zTask: s2, fieldArchiveID: fieldArchiveID1, createdAt: date2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZField.dedupe(testContext, taskArchiveID: taskArchiveID1, fieldArchiveID: fieldArchiveID1, inStore: mainStore)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertFalse(s2.isDeleted)
        XCTAssertFalse(f1.isDeleted)
        XCTAssertFalse(f2.isDeleted)
    }

    func testDupeConsolidateMFieldRuns() throws {
        let c1 = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: name1, createdAt: date1, toStore: mainStore)
        let s1 = ZTask.create(testContext, zRoutine: c1, taskArchiveID: taskArchiveID1, taskName: name1, createdAt: date1, toStore: mainStore)

        // same fieldArchiveID
        let f1 = ZField.create(testContext, zTask: s1, fieldArchiveID: fieldArchiveID1, createdAt: date1, toStore: mainStore)
        let f2 = ZField.create(testContext, zTask: s1, fieldArchiveID: fieldArchiveID1, createdAt: date2, toStore: mainStore)

        // note: does not dedupe task runs; it only consolidates them
        let rr = ZRoutineRun.create(testContext, zRoutine: c1, startedAt: startedAt1, toStore: mainStore)
        let dr = ZTaskRun.create(testContext, zRoutineRun: rr, zTask: s1, completedAt: completedAt1, toStore: mainStore)
        let r1 = ZFieldRun.create(testContext, zTaskRun: dr, zField: f1, toStore: mainStore)
        r1.value = "10"
        let r2 = ZFieldRun.create(testContext, zTaskRun: dr, zField: f1, toStore: mainStore)
        r2.value = "11"
        try testContext.save() // needed for fetch request to work properly

        try ZField.dedupe(testContext, taskArchiveID: taskArchiveID1, fieldArchiveID: fieldArchiveID1, inStore: mainStore)

        XCTAssertFalse(f1.isDeleted)
        XCTAssertTrue(f2.isDeleted)
        XCTAssertFalse(r1.isDeleted)
        XCTAssertFalse(r2.isDeleted)

        XCTAssertEqual(2, f1.zFieldRuns?.count) // consolidated
        XCTAssertEqual(0, f2.zFieldRuns?.count)
    }
}
