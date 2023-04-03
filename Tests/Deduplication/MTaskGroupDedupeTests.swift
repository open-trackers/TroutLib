//
//  MTaskGroupDedupeTests.swift
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

final class MTaskGroupDedupeTests: TestBase {
    let catArchiveID1 = UUID()
    let catArchiveID2 = UUID()
    let groupRaw1: Int16 = 5
    let groupRaw2: Int16 = 7

    let date0Str = "2023-01-01T21:00:01Z"
    var date0: Date!
    let date1Str = "2023-01-02T21:00:01Z"
    var date1: Date!
    let date2Str = "2023-01-02T21:00:02Z"
    var date2: Date!

    override func setUpWithError() throws {
        try super.setUpWithError()

        date0 = df.date(from: date0Str)
        date1 = df.date(from: date1Str)
        date2 = df.date(from: date2Str)
    }

    func testDifferentGroupRaw() throws {
        let c1 = MRoutine.create(testContext, userOrder: 10, archiveID: catArchiveID1, createdAt: date0)
        let s1 = MTaskGroup.create(testContext, routine: c1, userOrder: 4, groupRaw: groupRaw1, createdAt: date1)
        let s2 = MTaskGroup.create(testContext, routine: c1, userOrder: 8, groupRaw: groupRaw2, createdAt: date2)
        try testContext.save() // needed for fetch request to work properly

        try MTaskGroup.dedupe(testContext, routineArchiveID: catArchiveID1, groupRaw: groupRaw1)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertFalse(s2.isDeleted)
    }

    func testSameGroupRawWithinRoutine() throws {
        let c1 = MRoutine.create(testContext, userOrder: 10, archiveID: catArchiveID1, createdAt: date0)
        let s1 = MTaskGroup.create(testContext, routine: c1, userOrder: 4, groupRaw: groupRaw1, createdAt: date1)
        let s2 = MTaskGroup.create(testContext, routine: c1, userOrder: 8, groupRaw: groupRaw1, createdAt: date2)
        try testContext.save() // needed for fetch request to work properly

        try MTaskGroup.dedupe(testContext, routineArchiveID: catArchiveID1, groupRaw: groupRaw1)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertTrue(s2.isDeleted)
    }

    func testSameGroupRawOutsideRoutine() throws {
        let c1 = MRoutine.create(testContext, userOrder: 10, archiveID: catArchiveID1, createdAt: date1)
        let c2 = MRoutine.create(testContext, userOrder: 11, archiveID: catArchiveID2, createdAt: date2)
        let s1 = MTaskGroup.create(testContext, routine: c1, userOrder: 4, groupRaw: groupRaw1, createdAt: date1)
        let s2 = MTaskGroup.create(testContext, routine: c2, userOrder: 8, groupRaw: groupRaw1, createdAt: date2)
        try testContext.save() // needed for fetch request to work properly

        try MTaskGroup.dedupe(testContext, routineArchiveID: catArchiveID1, groupRaw: groupRaw1)

        XCTAssertFalse(c1.isDeleted)
        XCTAssertFalse(c2.isDeleted)
        XCTAssertFalse(s1.isDeleted)
        XCTAssertFalse(s2.isDeleted)
    }
}
