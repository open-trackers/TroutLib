//
//  UpdateRecordsTests.swift
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

final class UpdateRecordsTests: TestBase {
    let routineArchiveID = UUID()
    let taskArchiveID = UUID()

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    func testUpdateMRoutineArchiveID() throws {
        let r = MRoutine.create(testContext, userOrder: 0, name: "blah", archiveID: routineArchiveID)
        r.archiveID = nil
        try testContext.save()
        let r1: MRoutine? = MRoutine.get(testContext, forURIRepresentation: r.uriRepresentation)
        XCTAssertNil(r1?.archiveID)
        try updateArchiveIDs(testContext)
        let r2: MRoutine? = MRoutine.get(testContext, forURIRepresentation: r.uriRepresentation)
        XCTAssertNotNil(r2?.archiveID)
    }

    func testUpdateMTaskArchiveID() throws {
        let r = MRoutine.create(testContext, userOrder: 0, name: "blah", archiveID: routineArchiveID)
        let e = MTask.create(testContext, routine: r, userOrder: 0, name: "blah", archiveID: taskArchiveID)
        e.archiveID = nil
        try testContext.save()
        let e1: MTask? = MTask.get(testContext, forURIRepresentation: e.uriRepresentation)
        XCTAssertNil(e1?.archiveID)
        try updateArchiveIDs(testContext)
        let e2: MTask? = MTask.get(testContext, forURIRepresentation: e.uriRepresentation)
        XCTAssertNotNil(e2?.archiveID)
    }

    func testUpdateMRoutineCreatedAt() throws {
        let r = MRoutine.create(testContext, userOrder: 0, name: "blah", archiveID: routineArchiveID)
        r.createdAt = nil
        try testContext.save()
        let r1: MRoutine? = MRoutine.get(testContext, forURIRepresentation: r.uriRepresentation)
        XCTAssertNil(r1?.createdAt)
        try updateCreatedAts(testContext)
        let r2: MRoutine? = MRoutine.get(testContext, forURIRepresentation: r.uriRepresentation)
        XCTAssertNotNil(r2?.createdAt)
    }

    func testUpdateMTaskCreatedAt() throws {
        let r = MRoutine.create(testContext, userOrder: 0, name: "blah", archiveID: routineArchiveID)
        let e = MTask.create(testContext, routine: r, userOrder: 0, name: "blah", archiveID: taskArchiveID)
        e.createdAt = nil
        try testContext.save()
        let e1: MTask? = MTask.get(testContext, forURIRepresentation: e.uriRepresentation)
        XCTAssertNil(e1?.createdAt)
        try updateCreatedAts(testContext)
        let e2: MTask? = MTask.get(testContext, forURIRepresentation: e.uriRepresentation)
        XCTAssertNotNil(e2?.createdAt)
    }

    func testUpdateZRoutineCreatedAt() throws {
        let r = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        r.createdAt = nil
        try testContext.save()
        let e1: ZRoutine? = ZRoutine.get(testContext, forURIRepresentation: r.uriRepresentation)
        XCTAssertNil(e1?.createdAt)
        try updateCreatedAts(testContext)
        let e2: ZRoutine? = ZRoutine.get(testContext, forURIRepresentation: r.uriRepresentation)
        XCTAssertNotNil(e2?.createdAt)
    }

    func testUpdateZTaskCreatedAt() throws {
        let r = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let e = ZTask.create(testContext, zRoutine: r, taskArchiveID: taskArchiveID, taskName: "bleh", toStore: mainStore)
        e.createdAt = nil
        try testContext.save()
        let e1: ZTask? = ZTask.get(testContext, forURIRepresentation: e.uriRepresentation)
        XCTAssertNil(e1?.createdAt)
        try updateCreatedAts(testContext)
        let e2: ZTask? = ZTask.get(testContext, forURIRepresentation: e.uriRepresentation)
        XCTAssertNotNil(e2?.createdAt)
    }

    func testUpdateZRoutineRunCreatedAt() throws {
        let r = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: Date.now, elapsedSecs: 10, toStore: mainStore)
        rr.createdAt = nil
        try testContext.save()
        let e1: ZRoutineRun? = ZRoutineRun.get(testContext, forURIRepresentation: rr.uriRepresentation)
        XCTAssertNil(e1?.createdAt)
        try updateCreatedAts(testContext)
        let e2: ZRoutineRun? = ZRoutineRun.get(testContext, forURIRepresentation: rr.uriRepresentation)
        XCTAssertNotNil(e2?.createdAt)
    }

    func testUpdateZTaskRunCreatedAt() throws {
        let r = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let e = ZTask.create(testContext, zRoutine: r, taskArchiveID: taskArchiveID, taskName: "bleh", toStore: mainStore)
        let rr = ZRoutineRun.create(testContext, zRoutine: r, startedAt: Date.now, elapsedSecs: 10, toStore: mainStore)
        let er = ZTaskRun.create(testContext, zRoutineRun: rr, zTask: e, completedAt: Date.now, toStore: mainStore)
        er.createdAt = nil
        try testContext.save()
        let e1: ZTaskRun? = ZTaskRun.get(testContext, forURIRepresentation: er.uriRepresentation)
        XCTAssertNil(e1?.createdAt)
        try updateCreatedAts(testContext)
        let e2: ZTaskRun? = ZTaskRun.get(testContext, forURIRepresentation: er.uriRepresentation)
        XCTAssertNotNil(e2?.createdAt)
    }
}
