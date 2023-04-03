//
//  RoutineClearCompletionTests.swift
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

import Foundation

final class RoutineClearCompletionTests: TestBase {
    let routineArchiveID = UUID()
    let taskArchiveID = UUID()
    let fieldArchiveID1 = UUID()
    let fieldArchiveID2 = UUID()
    let fieldArchiveID3 = UUID()
    let fieldArchiveID4 = UUID()
    let fieldArchiveID5 = UUID()
    let fieldArchiveID6 = UUID()
    let fieldArchiveID7 = UUID()
    let fieldArchiveID8 = UUID()
    let now = Date.now
    let earlier = Date.now.addingTimeInterval(-1000)

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    func testClearBoolFields() throws {
        let r = MRoutine.create(testContext, userOrder: 5, name: "blink 0", archiveID: routineArchiveID, createdAt: earlier)
        let t = MTask.create(testContext, routine: r, userOrder: 18, name: "bleh", archiveID: taskArchiveID, createdAt: earlier)
        _ = MFieldBool.create(testContext, task: t, name: "foo1", userOrder: 1, clearOnRun: false, archiveID: fieldArchiveID1, createdAt: earlier, value: false)
        _ = MFieldBool.create(testContext, task: t, name: "foo2", userOrder: 2, clearOnRun: false, archiveID: fieldArchiveID2, createdAt: earlier, value: true)
        _ = MFieldBool.create(testContext, task: t, name: "foo3", userOrder: 3, clearOnRun: false, archiveID: fieldArchiveID3, createdAt: earlier, value: false)
        _ = MFieldBool.create(testContext, task: t, name: "foo4", userOrder: 4, clearOnRun: false, archiveID: fieldArchiveID4, createdAt: earlier, value: true)
        _ = MFieldBool.create(testContext, task: t, name: "foo5", userOrder: 5, clearOnRun: true, archiveID: fieldArchiveID5, createdAt: earlier, value: false)
        _ = MFieldBool.create(testContext, task: t, name: "foo6", userOrder: 6, clearOnRun: true, archiveID: fieldArchiveID6, createdAt: earlier, value: true)
        _ = MFieldBool.create(testContext, task: t, name: "foo7", userOrder: 7, clearOnRun: true, archiveID: fieldArchiveID7, createdAt: earlier, value: false)
        _ = MFieldBool.create(testContext, task: t, name: "foo8", userOrder: 8, clearOnRun: true, archiveID: fieldArchiveID8, createdAt: earlier, value: true)
        t.lastCompletedAt = now
        try testContext.save()

        try r.clearTaskCompletions(testContext)
        try testContext.save()

        let cr = try MRoutine.get(testContext, archiveID: routineArchiveID)
        let ct = cr!.tasksArray.first!

        XCTAssertNil(ct.lastCompletedAt)

        let fields = ct.fieldsArray.sorted(by: { $0.userOrder < $1.userOrder })

        XCTAssertFalse((fields[0] as! MFieldBool).value)
        XCTAssertTrue((fields[1] as! MFieldBool).value)
        XCTAssertFalse((fields[2] as! MFieldBool).value)
        XCTAssertTrue((fields[3] as! MFieldBool).value)
        XCTAssertFalse((fields[4] as! MFieldBool).value)
        XCTAssertFalse((fields[5] as! MFieldBool).value)
        XCTAssertFalse((fields[6] as! MFieldBool).value)
        XCTAssertFalse((fields[7] as! MFieldBool).value)
    }

    func testClearInt16Fields() throws {
        let r = MRoutine.create(testContext, userOrder: 5, name: "blink 0", archiveID: routineArchiveID, createdAt: earlier)
        let t = MTask.create(testContext, routine: r, userOrder: 18, name: "bleh", archiveID: taskArchiveID, createdAt: earlier)
        _ = MFieldInt16.create(testContext, task: t, name: "foo1", userOrder: 1, clearOnRun: false, archiveID: fieldArchiveID1, createdAt: earlier, defaultValue: 0, value: 0)
        _ = MFieldInt16.create(testContext, task: t, name: "foo2", userOrder: 2, clearOnRun: false, archiveID: fieldArchiveID2, createdAt: earlier, defaultValue: 0, value: 1)
        _ = MFieldInt16.create(testContext, task: t, name: "foo3", userOrder: 3, clearOnRun: false, archiveID: fieldArchiveID3, createdAt: earlier, defaultValue: 1, value: 0)
        _ = MFieldInt16.create(testContext, task: t, name: "foo4", userOrder: 4, clearOnRun: false, archiveID: fieldArchiveID4, createdAt: earlier, defaultValue: 1, value: 1)
        _ = MFieldInt16.create(testContext, task: t, name: "foo5", userOrder: 5, clearOnRun: true, archiveID: fieldArchiveID5, createdAt: earlier, defaultValue: 0, value: 0)
        _ = MFieldInt16.create(testContext, task: t, name: "foo6", userOrder: 6, clearOnRun: true, archiveID: fieldArchiveID6, createdAt: earlier, defaultValue: 0, value: 1)
        _ = MFieldInt16.create(testContext, task: t, name: "foo7", userOrder: 7, clearOnRun: true, archiveID: fieldArchiveID7, createdAt: earlier, defaultValue: 1, value: 0)
        _ = MFieldInt16.create(testContext, task: t, name: "foo8", userOrder: 8, clearOnRun: true, archiveID: fieldArchiveID8, createdAt: earlier, defaultValue: 1, value: 1)
        t.lastCompletedAt = now
        try testContext.save()

        try r.clearTaskCompletions(testContext)
        try testContext.save()

        let cr = try MRoutine.get(testContext, archiveID: routineArchiveID)
        let ct = cr!.tasksArray.first!

        XCTAssertNil(ct.lastCompletedAt)

        let fields = ct.fieldsArray.sorted(by: { $0.userOrder < $1.userOrder })

        XCTAssertEqual(0, (fields[0] as! MFieldInt16).value)
        XCTAssertEqual(1, (fields[1] as! MFieldInt16).value)
        XCTAssertEqual(0, (fields[2] as! MFieldInt16).value)
        XCTAssertEqual(1, (fields[3] as! MFieldInt16).value)
        XCTAssertEqual(0, (fields[4] as! MFieldInt16).value)
        XCTAssertEqual(0, (fields[5] as! MFieldInt16).value)
        XCTAssertEqual(1, (fields[6] as! MFieldInt16).value)
        XCTAssertEqual(1, (fields[7] as! MFieldInt16).value)
    }
}
