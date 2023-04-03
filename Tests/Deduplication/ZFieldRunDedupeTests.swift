//
//  ZFieldRunDedupeTests.swift
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

final class ZFieldRunDedupeTests: TestBase {
    let routineArchiveID1 = UUID()
    let routineArchiveID2 = UUID()
    let taskArchiveID1 = UUID()
    let taskArchiveID2 = UUID()
    let fieldArchiveID = UUID()

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

    func testDifferentTaskRuns() throws {
        let zr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: "blah", createdAt: date1, toStore: mainStore)
        let c1 = ZTask.create(testContext, zRoutine: zr, taskArchiveID: routineArchiveID1, taskName: name1, createdAt: date1, toStore: mainStore)
        let s1 = ZField.create(testContext, zTask: c1, fieldArchiveID: fieldArchiveID, fieldName: name1, createdAt: date1, toStore: mainStore)
        let rr = ZRoutineRun.create(testContext, zRoutine: zr, startedAt: startedAt1, toStore: mainStore)

        let dr1 = ZTaskRun.create(testContext, zRoutineRun: rr, zTask: c1, completedAt: completedAt1, createdAt: date1, toStore: mainStore)
        let dr2 = ZTaskRun.create(testContext, zRoutineRun: rr, zTask: c1, completedAt: completedAt2, createdAt: date1, toStore: mainStore)

        let r1 = ZFieldRun.create(testContext, zTaskRun: dr1, zField: s1, createdAt: date1, toStore: mainStore)
        let r2 = ZFieldRun.create(testContext, zTaskRun: dr2, zField: s1, createdAt: date2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZFieldRun.dedupe(testContext,
                             fieldArchiveID: fieldArchiveID,
                             // startedAt: startedAt1,
                             completedAt: completedAt1,
                             inStore: mainStore)

        XCTAssertFalse(r1.isDeleted)
        XCTAssertFalse(r2.isDeleted)
    }

    func testSameConsumedTime() throws {
        let zr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID1, routineName: "blah", createdAt: date1, toStore: mainStore)
        let c1 = ZTask.create(testContext, zRoutine: zr, taskArchiveID: routineArchiveID1, taskName: name1, createdAt: date1, toStore: mainStore)
        let s1 = ZField.create(testContext, zTask: c1, fieldArchiveID: fieldArchiveID, fieldName: name1, createdAt: date1, toStore: mainStore)
        let rr = ZRoutineRun.create(testContext, zRoutine: zr, startedAt: startedAt1, toStore: mainStore)

        let dr1 = ZTaskRun.create(testContext, zRoutineRun: rr, zTask: c1, completedAt: completedAt1, createdAt: date1, toStore: mainStore)

        let r1 = ZFieldRun.create(testContext, zTaskRun: dr1, zField: s1, createdAt: date1, toStore: mainStore)
        let r2 = ZFieldRun.create(testContext, zTaskRun: dr1, zField: s1, createdAt: date2, toStore: mainStore)
        try testContext.save() // needed for fetch request to work properly

        try ZFieldRun.dedupe(testContext,
                             fieldArchiveID: fieldArchiveID,
                             // startedAt: startedAt1,
                             completedAt: completedAt1,
                             inStore: mainStore)

        XCTAssertFalse(r1.isDeleted)
        XCTAssertTrue(r2.isDeleted)
    }
}
