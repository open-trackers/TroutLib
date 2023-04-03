//
//  ExportTests.swift
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

// TODO: test for MFieldBool
// TODO: test for MFieldInt16

final class ExportTests: TestBase {
    let routineArchiveID = UUID()
    let taskArchiveID = UUID()
    let fieldArchiveID = UUID()

    let startedAtStr = "2023-01-13T20:42:50Z"
    var startedAt: Date!
    let pausedAtStr = "2023-01-13T20:52:50Z"
    var pausedAt: Date!
//    let resumedAtStr = "2023-01-13T20:58:50Z"
//    var resumedAt: Date!
    let completedAtStr = "2023-01-13T21:00:00Z"
    var completedAt: Date!
    let createdAtStr = "2023-01-01T01:00:00Z"
    var createdAt: Date!

    let elapsedSecsStr = "1332.0"
    var elapsedSecs: TimeInterval!
    let intensityStr = "105.5"
    var intensity: Float!
    let intensityStepStr = "3.3"
    var intensityStep: Float!
    let userOrderStr = "18"
    var userOrder: Int16!

    override func setUpWithError() throws {
        try super.setUpWithError()

        startedAt = df.date(from: startedAtStr)
        pausedAt = df.date(from: pausedAtStr)
        // resumedAt = df.date(from: resumedAtStr)
        completedAt = df.date(from: completedAtStr)
        createdAt = df.date(from: createdAtStr)
        elapsedSecs = Double(elapsedSecsStr)
        intensity = Float(intensityStr)
        intensityStep = Float(intensityStepStr)
        userOrder = Int16(userOrderStr)
    }

    func testZRoutine() throws {
        _ = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", createdAt: createdAt, toStore: mainStore)
        try testContext.save()

        let request = makeRequest(ZRoutine.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        name,routineArchiveID,createdAt
        blah,\(routineArchiveID.uuidString),\(createdAtStr)

        """

        XCTAssertEqual(expected, actual)
    }

    func testZRoutineRun() throws {
        let zr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let zrr = ZRoutineRun.create(testContext, zRoutine: zr, startedAt: startedAt, elapsedSecs: elapsedSecs, createdAt: createdAt, toStore: mainStore)
        zrr.userRemoved = true
        // zrr.pausedAt = pausedAt
        try testContext.save()

        let request = makeRequest(ZRoutineRun.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        startedAt,elapsedSecs,userRemoved,createdAt,routineArchiveID
        \(startedAtStr),\(elapsedSecsStr),true,\(createdAtStr),\(routineArchiveID.uuidString)

        """

        XCTAssertEqual(expected, actual)
    }

    func testZTask() throws {
        let zr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        _ = ZTask.create(testContext, zRoutine: zr, taskArchiveID: taskArchiveID, taskName: "bleh", createdAt: createdAt, toStore: mainStore)
        try testContext.save()

        let request = makeRequest(ZTask.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        name,taskArchiveID,createdAt,routineArchiveID
        bleh,\(taskArchiveID.uuidString),\(createdAtStr),\(routineArchiveID.uuidString)

        """

        XCTAssertEqual(expected, actual)
    }

    func testZField() throws {
        let zr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let zt = ZTask.create(testContext, zRoutine: zr, taskArchiveID: taskArchiveID, taskName: "bleh", createdAt: createdAt, toStore: mainStore)
        let f1 = ZField.create(testContext, zTask: zt, fieldArchiveID: fieldArchiveID, createdAt: createdAt, toStore: mainStore)
        f1.name = "blort"
        f1.unitsSuffix = "lbs"
        try testContext.save()

        let request = makeRequest(ZField.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        name,unitsSuffix,fieldArchiveID,createdAt,taskArchiveID
        blort,lbs,\(fieldArchiveID.uuidString),\(createdAtStr),\(taskArchiveID.uuidString)

        """

        XCTAssertEqual(expected, actual)
    }

    func testZTaskRun() throws {
        let zr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let ze = ZTask.create(testContext, zRoutine: zr, taskArchiveID: taskArchiveID, taskName: "bleh", toStore: mainStore)
        let zrr = ZRoutineRun.create(testContext, zRoutine: zr, startedAt: startedAt, elapsedSecs: elapsedSecs, toStore: mainStore)
        let zer = ZTaskRun.create(testContext, zRoutineRun: zrr, zTask: ze, completedAt: completedAt, createdAt: createdAt, toStore: mainStore)
        zer.userRemoved = true
        try testContext.save()

        let request = makeRequest(ZTaskRun.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        completedAt,userRemoved,createdAt,taskArchiveID,routineRunStartedAt
        \(completedAtStr),true,\(createdAtStr),\(taskArchiveID.uuidString),\(startedAtStr)

        """

        XCTAssertEqual(expected, actual)
    }

    func testMRoutine() throws {
        let r = MRoutine.create(testContext, userOrder: userOrder, name: "bleh", archiveID: routineArchiveID, createdAt: createdAt)
        r.lastDuration = elapsedSecs
        r.lastStartedAt = startedAt
        r.imageName = "bloop"
        r.isTemplate = true
        r.pausedAt = pausedAt
        // r.resumedAt = resumedAt
        try testContext.save()

        let request = makeRequest(MRoutine.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        archiveID,imageName,lastDuration,lastStartedAt,name,isTemplate,pausedAt,userOrder,createdAt
        \(routineArchiveID.uuidString),bloop,\(elapsedSecsStr),\(startedAtStr),bleh,true,\(pausedAtStr),\(userOrderStr),\(createdAtStr)

        """

        XCTAssertEqual(expected, actual)
    }

    func testMTask() throws {
        let r = MRoutine.create(testContext, userOrder: 77, name: "bleh", archiveID: routineArchiveID)
        let e = MTask.create(testContext, routine: r, userOrder: userOrder, name: "bleep", archiveID: taskArchiveID, createdAt: createdAt)
        e.routine = r
        e.lastCompletedAt = completedAt
        try testContext.save()

        let request = makeRequest(MTask.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .CSV)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let expected = """
        archiveID,lastCompletedAt,name,userOrder,createdAt,routineArchiveID
        \(taskArchiveID.uuidString),\(completedAtStr),bleep,\(userOrderStr),\(createdAtStr),\(routineArchiveID)

        """

        XCTAssertEqual(expected, actual)
    }

    func testMRoutineJSON() throws {
        let r = MRoutine.create(testContext, userOrder: userOrder, name: "bleh", archiveID: routineArchiveID, createdAt: createdAt)
        r.lastDuration = elapsedSecs
        r.lastStartedAt = startedAt
        r.imageName = "bloop"
        r.isTemplate = true
        r.pausedAt = pausedAt
        // r.resumedAt = resumedAt
        try testContext.save()

        let request = makeRequest(MRoutine.self)
        let results = try testContext.fetch(request)
        let data = try exportData(results, format: .JSON)
        guard let actual = String(data: data, encoding: .utf8) else { XCTFail(); return }

        let elapsedSecsStr2 = "1332" // JSON doesn't include the ".0"

        let expected = """
        [{"name":"bleh","lastStartedAt":"\(startedAtStr)","createdAt":"\(createdAtStr)","userOrder":\(userOrderStr),"lastDuration":\(elapsedSecsStr2),"isTemplate":true,"imageName":"bloop","archiveID":"\(routineArchiveID.uuidString)","pausedAt":"\(pausedAtStr)"}]
        """

        XCTAssertEqual(expected, actual)
    }

    // TODO: JSON export for the other types
}
