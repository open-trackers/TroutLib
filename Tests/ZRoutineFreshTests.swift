//
//  ZRoutineFreshTests.swift
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

// TODO: fresh if open; stale if closed and older than N days

final class ZRoutineFreshTests: TestBase {
    let routineArchiveID = UUID()
    let taskArchiveID = UUID()
    let secondsPerDay: TimeInterval = 86400

    let thresholdSecs: TimeInterval = 86400

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    func testMissingMRoutineIsStale() throws {
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        try testContext.save()

        XCTAssertFalse(sr.isFresh(testContext, thresholdSecs: thresholdSecs))
    }

    func testMissingLastStartedAtIsStale() throws {
        let r = MRoutine.create(testContext, userOrder: 1, archiveID: routineArchiveID)

        XCTAssertNil(r.lastStartedAt)

        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        try testContext.save()

        XCTAssertFalse(sr.isFresh(testContext, thresholdSecs: thresholdSecs))
    }

    func testThresholdSecond() throws {
        let base = Date.now
        let lastStartedAt = base.addingTimeInterval(-1) // one second prior

        let r = MRoutine.create(testContext, userOrder: 1, archiveID: routineArchiveID)
        r.lastStartedAt = lastStartedAt

        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        try testContext.save()

        // if within the threshold, it's fresh
        XCTAssertTrue(sr.isFresh(testContext, thresholdSecs: 2, now: base))
        XCTAssertTrue(sr.isFresh(testContext, thresholdSecs: 1, now: base))

        // if outside the threshold, it's stale
        XCTAssertFalse(sr.isFresh(testContext, thresholdSecs: 0, now: base))
    }

    func testThresholdHour() throws {
        let base = Date.now
        let lastStartedAt = base.addingTimeInterval(-3600) // one hour prior

        let r = MRoutine.create(testContext, userOrder: 1, archiveID: routineArchiveID)
        r.lastStartedAt = lastStartedAt

        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        try testContext.save()

        // if within the threshold, it's fresh
        XCTAssertTrue(sr.isFresh(testContext, thresholdSecs: secondsPerDay, now: base))
        XCTAssertTrue(sr.isFresh(testContext, thresholdSecs: 3601, now: base))
        XCTAssertTrue(sr.isFresh(testContext, thresholdSecs: 3600, now: base))

        // if outside the threshold, it's stale
        XCTAssertFalse(sr.isFresh(testContext, thresholdSecs: 3599, now: base))
        XCTAssertFalse(sr.isFresh(testContext, thresholdSecs: 0, now: base))
    }

    func testTransferPreservesFreshMRoutine() throws {
        let base = Date.now
        let lastStartedAt = base.addingTimeInterval(-secondsPerDay) // less than or equal to a day prior (fresh, so preserve)

        let r = MRoutine.create(testContext, userOrder: 1, archiveID: routineArchiveID)
        r.lastStartedAt = lastStartedAt
        _ = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))

        try transferToArchive(testContext, mainStore: mainStore, archiveStore: archiveStore, thresholdSecs: secondsPerDay, now: base)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore)) // preserved!
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
    }

    func testTransferPurgesStaleMRoutine() throws {
        let base = Date.now
        let lastStartedAt = base.addingTimeInterval(-secondsPerDay - 1) // more than one day prior (stale, so purge)

        let r = MRoutine.create(testContext, userOrder: 1, archiveID: routineArchiveID)
        r.lastStartedAt = lastStartedAt
        _ = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))

        try transferToArchive(testContext, mainStore: mainStore, archiveStore: archiveStore, thresholdSecs: secondsPerDay, now: base)
        try testContext.save()

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore)) // purged!
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
    }
}
