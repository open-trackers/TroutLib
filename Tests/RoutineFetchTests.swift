//
//  RoutineFetchTests.swift
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

final class RoutineFetchTests: TestBase {
    let routineArchiveID = UUID()
    let taskArchiveID = UUID()

    func testGetToRunNotFound() throws {
        let c = MRoutine.create(testContext, userOrder: 5, name: "blink 0", archiveID: routineArchiveID)
        let t = MTask.create(testContext, routine: c, userOrder: 18, name: "bleh", archiveID: taskArchiveID)
        try testContext.save()
        XCTAssertThrowsError(try MRoutine.getToRun(testContext, t.uriRepresentation)) { error in
            XCTAssertEqual(TrackerError.missingData(msg: "Routine not found."), error as! TrackerError)
        }
    }

    func testGetToRun() throws {
        let c = MRoutine.create(testContext, userOrder: 5, name: "blink", archiveID: routineArchiveID)
        c.isTemplate = false
        try testContext.save()

        let c2 = try MRoutine.getToRun(testContext, c.uriRepresentation)
        XCTAssertEqual(c.archiveID, c2.archiveID)
    }

    func testGetToRunTemplate() throws {
        let c = MRoutine.create(testContext, userOrder: 5, name: "blink", archiveID: routineArchiveID)
        c.isTemplate = true
        try testContext.save()

        let c2 = try MRoutine.getToRun(testContext, c.uriRepresentation)
        XCTAssertNotEqual(c.archiveID, c2.archiveID)
    }
}
