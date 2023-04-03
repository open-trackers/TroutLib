//
//  MRoutineDedupeTests.swift
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

final class MRoutineDedupeTests: TestBase {
    let routineArchiveID1 = UUID()
    let routineArchiveID2 = UUID()
    let taskArchiveID1 = UUID()
    let taskArchiveID2 = UUID()
    let groupRaw1: Int16 = 5
    let groupRaw2: Int16 = 7

    let date1Str = "2023-01-02T21:00:01Z"
    var date1: Date!
    let date2Str = "2023-01-02T21:00:02Z"
    var date2: Date!

    override func setUpWithError() throws {
        try super.setUpWithError()

        date1 = df.date(from: date1Str)
        date2 = df.date(from: date2Str)
    }

    func testDifferentArchiveID() throws {
        let c1 = MRoutine.create(testContext, userOrder: 10, archiveID: routineArchiveID1, createdAt: date1)
        let c2 = MRoutine.create(testContext, userOrder: 15, archiveID: routineArchiveID2, createdAt: date2)
        try testContext.save() // needed for fetch request to work properly

        try MRoutine.dedupe(testContext, archiveID: routineArchiveID1)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertFalse(c2.isDeleted)
    }

    func testSameArchiveID() throws {
        let c1 = MRoutine.create(testContext, userOrder: 10, archiveID: routineArchiveID1, createdAt: date1)
        let c2 = MRoutine.create(testContext, userOrder: 15, archiveID: routineArchiveID1, createdAt: date2)
        try testContext.save() // needed for fetch request to work properly

        try MRoutine.dedupe(testContext, archiveID: routineArchiveID1)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertTrue(c2.isDeleted)
    }

    func testDupeConsolidateTasks() throws {
        let c1 = MRoutine.create(testContext, userOrder: 10, archiveID: routineArchiveID1, createdAt: date1)
        let c2 = MRoutine.create(testContext, userOrder: 15, archiveID: routineArchiveID1, createdAt: date2)

        let s1 = MTask.create(testContext, routine: c1, userOrder: 4, archiveID: taskArchiveID1)
        let s2 = MTask.create(testContext, routine: c2, userOrder: 8, archiveID: taskArchiveID2)
        try testContext.save() // needed for fetch request to work properly

        try MRoutine.dedupe(testContext, archiveID: routineArchiveID1)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertTrue(c2.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertFalse(s2.isDeleted)

        XCTAssertEqual(2, c1.tasks?.count) // consolidated
        XCTAssertEqual(0, c2.tasks?.count)
    }

    func testDupeConsolidateFoodGroups() throws {
        let c1 = MRoutine.create(testContext, userOrder: 10, archiveID: routineArchiveID1, createdAt: date1)
        let c2 = MRoutine.create(testContext, userOrder: 15, archiveID: routineArchiveID1, createdAt: date2)

        let s1 = MTaskGroup.create(testContext, routine: c1, userOrder: 4, groupRaw: groupRaw1, createdAt: date1)
        let s2 = MTaskGroup.create(testContext, routine: c2, userOrder: 8, groupRaw: groupRaw2, createdAt: date2)
        try testContext.save() // needed for fetch request to work properly

        try MRoutine.dedupe(testContext, archiveID: routineArchiveID1)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertTrue(c2.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertFalse(s2.isDeleted)

        XCTAssertEqual(2, c1.taskGroups?.count) // consolidated
        XCTAssertEqual(0, c2.taskGroups?.count)
    }
}
