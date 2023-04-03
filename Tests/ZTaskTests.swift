//
//  ZTaskTests.swift
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

final class ZTaskTests: TestBase {
    let routineArchiveID = UUID()
    let taskArchiveID = UUID()

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    func testGetOrCreateUpdatesNameAndUnits() throws {
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        _ = ZTask.create(testContext, zRoutine: sr, taskArchiveID: taskArchiveID, taskName: "bleh", toStore: mainStore)
        try testContext.save()

        let se2 = try ZTask.getOrCreate(testContext,
                                        zRoutine: sr,
                                        taskArchiveID: taskArchiveID,
//                                            taskName: "bleh2",
//                                            taskUnits: .pounds,
                                        inStore: mainStore)
        { _, element in
            element.name = "bleh2"
            // element.units = Units.pounds.rawValue
        }
        try testContext.save()

        XCTAssertEqual("bleh2", se2.name)
        // XCTAssertEqual(Units.pounds.rawValue, se2.units)
    }
}
