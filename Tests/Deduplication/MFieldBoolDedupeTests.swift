//
//  MFieldBoolDedupeTests.swift
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

final class MFieldBoolDedupeTests: TestBase {
    let routineArchiveID1 = UUID()
    let taskArchiveID1 = UUID()
    let taskArchiveID2 = UUID()
    let fieldArchiveID1 = UUID()
    let fieldArchiveID2 = UUID()

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
        let c1 = MRoutine.create(testContext, userOrder: 1, archiveID: routineArchiveID1)
        let t1 = MTask.create(testContext, routine: c1, userOrder: 10, archiveID: taskArchiveID1, createdAt: date1)
        let s1 = MFieldBool.create(testContext, task: t1, name: "foo", userOrder: 4, archiveID: fieldArchiveID1, createdAt: date1, value: true)
        let s2 = MFieldBool.create(testContext, task: t1, name: "bar", userOrder: 8, archiveID: fieldArchiveID2, createdAt: date2, value: false)
        try testContext.save() // needed for fetch request to work properly

        try MFieldBool.dedupe(testContext, taskArchiveID: taskArchiveID1, fieldArchiveID: fieldArchiveID1)

        XCTAssertFalse(t1.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertFalse(s2.isDeleted)
    }

    func testSameArchiveIdWithinTask() throws {
        let c1 = MRoutine.create(testContext, userOrder: 1, archiveID: routineArchiveID1)
        let t1 = MTask.create(testContext, routine: c1, userOrder: 10, archiveID: taskArchiveID1, createdAt: date1)
        let s1 = MFieldBool.create(testContext, task: t1, name: "foo", userOrder: 4, archiveID: fieldArchiveID1, createdAt: date1, value: true)
        let s2 = MFieldBool.create(testContext, task: t1, name: "bar", userOrder: 8, archiveID: fieldArchiveID1, createdAt: date2, value: false)
        try testContext.save() // needed for fetch request to work properly

        try MFieldBool.dedupe(testContext, taskArchiveID: taskArchiveID1, fieldArchiveID: fieldArchiveID1)

        XCTAssertFalse(t1.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertTrue(s2.isDeleted)
    }

    func testSameArchiveIdOutsideTask() throws {
        let c1 = MRoutine.create(testContext, userOrder: 1, archiveID: routineArchiveID1)
        let t1 = MTask.create(testContext, routine: c1, userOrder: 10, archiveID: taskArchiveID1, createdAt: date1)
        let t2 = MTask.create(testContext, routine: c1, userOrder: 11, archiveID: taskArchiveID2, createdAt: date2)
        let s1 = MFieldBool.create(testContext, task: t1, name: "foo", userOrder: 4, archiveID: fieldArchiveID1, createdAt: date1, value: true)
        let s2 = MFieldBool.create(testContext, task: t2, name: "bar", userOrder: 8, archiveID: fieldArchiveID1, createdAt: date2, value: false)
        try testContext.save() // needed for fetch request to work properly

        try MFieldBool.dedupe(testContext, taskArchiveID: taskArchiveID1, fieldArchiveID: fieldArchiveID1)

        XCTAssertFalse(t1.isDeleted)
        XCTAssertFalse(t2.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertFalse(s2.isDeleted)
    }
}
