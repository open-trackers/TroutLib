//
//  TaskTests.swift
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

final class TaskTests: TestBase {
    let routineArchiveID = UUID()
    let taskArchiveID = UUID()

    func testGetByArchiveID() throws {
        let c = MRoutine.create(testContext, userOrder: 5, name: "blink 0", archiveID: routineArchiveID)
        _ = MTask.create(testContext, routine: c, userOrder: 18, name: "bleh", archiveID: taskArchiveID)
        try testContext.save()

        // ensure tasks are cleared
        guard try MTask.get(testContext, routineArchiveID: routineArchiveID, archiveID: taskArchiveID) != nil
        else { XCTFail(); return }

        guard try MRoutine.get(testContext, archiveID: routineArchiveID) != nil
        else { XCTFail(); return }
    }
}
