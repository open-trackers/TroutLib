//
//  LogCompletionTests.swift
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

final class LogCompletionTests: TestBase {
    let routineArchiveID = UUID()
    let taskArchiveID1 = UUID()
    let taskArchiveID2 = UUID()
    let fieldArchiveID1 = UUID()
    let fieldArchiveID2 = UUID()

    let startedAtStr = "2023-01-13T20:42:50Z"
    var startedAt: Date!
    let completedAt1Str = "2023-01-13T21:00:00Z"
    var completedAt1: Date!
    let completedAt2Str = "2023-01-13T21:10:00Z"
    var completedAt2: Date!

    let elapsedSecsStr = "1332.0"
    var elapsedSecs: TimeInterval!
    let intensity1Str = "105.5"
    var intensity1: Float!
    let intensity2Str = "55.5"
    var intensity2: Float!
    let intensityStepStr = "3.3"
    var intensityStep: Float!
    let userOrder1Str = "18"
    var userOrder1: Int16!
    let userOrder2Str = "20"
    var userOrder2: Int16!

    let thresholdSecs: TimeInterval = 86400

    override func setUpWithError() throws {
        try super.setUpWithError()

        startedAt = df.date(from: startedAtStr)
        completedAt1 = df.date(from: completedAt1Str)
        completedAt2 = df.date(from: completedAt2Str)
        elapsedSecs = Double(elapsedSecsStr)
        intensity1 = Float(intensity1Str)
        intensity2 = Float(intensity2Str)
        intensityStep = Float(intensityStepStr)
        userOrder1 = Int16(userOrder1Str)
        userOrder2 = Int16(userOrder2Str)
    }

    func testBasic() throws {
        let r = MRoutine.create(testContext, userOrder: 77, name: "bleh", archiveID: routineArchiveID)
        let e = MTask.create(testContext, routine: r, userOrder: userOrder1, name: "bleep", archiveID: taskArchiveID1)
        let sBoolField = MFieldBool.create(testContext, task: e, name: "foo", userOrder: 1, archiveID: fieldArchiveID1, value: true)
        let sInt16Field = MFieldInt16.create(testContext, task: e, name: "bar", userOrder: 2, archiveID: fieldArchiveID2, value: 353, upperBound: 500, stepValue: 12)
        try testContext.save()

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID1, inStore: mainStore))
        XCTAssertNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID1, completedAt: completedAt1, inStore: mainStore))
        XCTAssertNil(try ZField.get(testContext, taskArchiveID: taskArchiveID1, fieldArchiveID: fieldArchiveID1, inStore: mainStore))
        XCTAssertNil(try ZField.get(testContext, taskArchiveID: taskArchiveID1, fieldArchiveID: fieldArchiveID2, inStore: mainStore))
        XCTAssertNil(try ZFieldRun.get(testContext, fieldArchiveID: fieldArchiveID1, completedAt: completedAt1, inStore: mainStore))
        XCTAssertNil(try ZFieldRun.get(testContext, fieldArchiveID: fieldArchiveID2, completedAt: completedAt1, inStore: mainStore))

        try e.logCompletion(testContext, mainStore: mainStore, startedAt: startedAt, elapsedSecs: elapsedSecs, taskCompletedAt: completedAt1)
        try testContext.save()

        let zr = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore)
        XCTAssertNotNil(zr)
        XCTAssertEqual(r.name, zr?.name)
        let zrr = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore)
        XCTAssertNotNil(zrr)
        XCTAssertEqual(elapsedSecs, zrr?.elapsedSecs)
        XCTAssertEqual(startedAt, zrr?.startedAt)
        let ze = try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID1, inStore: mainStore)
        XCTAssertNotNil(ze)
        XCTAssertEqual(e.name, ze?.name)
        let zer = try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID1, completedAt: completedAt1, inStore: mainStore)
        XCTAssertNotNil(zer)
        XCTAssertEqual(completedAt1, zer?.completedAt)

        let zf1 = try ZField.get(testContext, taskArchiveID: taskArchiveID1, fieldArchiveID: fieldArchiveID1, inStore: mainStore)
        XCTAssertNotNil(zf1)
        XCTAssertEqual(sBoolField.name, zf1?.name)

        let zf2 = try ZField.get(testContext, taskArchiveID: taskArchiveID1, fieldArchiveID: fieldArchiveID2, inStore: mainStore)
        XCTAssertNotNil(zf2)
        XCTAssertEqual(sInt16Field.name, zf2?.name)

        let zfr1 = try ZFieldRun.get(testContext, fieldArchiveID: fieldArchiveID1, completedAt: completedAt1, inStore: mainStore)
        XCTAssertNotNil(zfr1)
        XCTAssertEqual(String(sBoolField.value), zfr1?.value)

        let zfr2 = try ZFieldRun.get(testContext, fieldArchiveID: fieldArchiveID2, completedAt: completedAt1, inStore: mainStore)
        XCTAssertNotNil(zfr2)
        XCTAssertEqual(String(sInt16Field.value), zfr2?.value)
    }

    func testTaskRunAfterTransfer() throws {
        /// ensure that a transfer doesn't interfere with an actively running routine

        let r = MRoutine.create(testContext, userOrder: 77, name: "bleh", archiveID: routineArchiveID)
        let e1 = MTask.create(testContext, routine: r, userOrder: userOrder1, name: "bleep", archiveID: taskArchiveID1)
        e1.routine = r
//        e1.lastIntensity = intensity1

        let e2 = MTask.create(testContext, routine: r, userOrder: userOrder2, name: "blort", archiveID: taskArchiveID2)
        e2.routine = r
//        e2.lastIntensity = intensity2
        try testContext.save()

        try e1.logCompletion(testContext, mainStore: mainStore, startedAt: startedAt, elapsedSecs: elapsedSecs, taskCompletedAt: completedAt1)
        try testContext.save()

        XCTAssertNotNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID1, completedAt: completedAt1, inStore: mainStore))
        XCTAssertNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID1, completedAt: completedAt1, inStore: archiveStore))

        try transferToArchive(testContext, mainStore: mainStore, archiveStore: archiveStore, thresholdSecs: thresholdSecs)
        try testContext.save()

        XCTAssertNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID1, completedAt: completedAt1, inStore: mainStore))
        XCTAssertNotNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID1, completedAt: completedAt1, inStore: archiveStore))

        try e2.logCompletion(testContext, mainStore: mainStore, startedAt: startedAt, elapsedSecs: elapsedSecs, taskCompletedAt: completedAt2)
        try testContext.save()

        XCTAssertNotNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID2, completedAt: completedAt2, inStore: mainStore))
        XCTAssertNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID2, completedAt: completedAt2, inStore: archiveStore))

        try transferToArchive(testContext, mainStore: mainStore, archiveStore: archiveStore, thresholdSecs: thresholdSecs)
        try testContext.save()

        XCTAssertNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID2, completedAt: completedAt2, inStore: mainStore))
        XCTAssertNotNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID2, completedAt: completedAt2, inStore: archiveStore))

        let zr = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        XCTAssertNotNil(zr)
        XCTAssertEqual(r.name, zr?.name)
        let zrr = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore)
        XCTAssertNotNil(zrr)
        XCTAssertEqual(elapsedSecs, zrr?.elapsedSecs)
        XCTAssertEqual(startedAt, zrr?.startedAt)

        let ze1 = try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID1, inStore: archiveStore)
        XCTAssertNotNil(ze1)
        XCTAssertEqual(e1.name, ze1?.name)
//        XCTAssertEqual(e1.units, ze1?.units)
        let zer1 = try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID1, completedAt: completedAt1, inStore: archiveStore)
        XCTAssertNotNil(zer1)
        XCTAssertEqual(completedAt1, zer1?.completedAt)
//        XCTAssertEqual(intensity1, zer1?.intensity)

        let ze2 = try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID2, inStore: archiveStore)
        XCTAssertNotNil(ze2)
        XCTAssertEqual(e2.name, ze2?.name)
//        XCTAssertEqual(e2.units, ze2?.units)
        let zer2 = try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID2, completedAt: completedAt2, inStore: archiveStore)
        XCTAssertNotNil(zer2)
        XCTAssertEqual(completedAt2, zer2?.completedAt)
//        XCTAssertEqual(intensity2, zer2?.intensity)
    }

    func testRestoreRoutineRunAfterUserCompletesTask() throws {
        let r = MRoutine.create(testContext, userOrder: 77, name: "bleh", archiveID: routineArchiveID)
        let e1 = MTask.create(testContext, routine: r, userOrder: userOrder1, name: "bleep", archiveID: taskArchiveID1)
//        e1.lastIntensity = intensity1
        let e2 = MTask.create(testContext, routine: r, userOrder: userOrder2, name: "blort", archiveID: taskArchiveID1)
//        e2.lastIntensity = intensity2
        try testContext.save()

        try e1.logCompletion(testContext, mainStore: mainStore, startedAt: startedAt, elapsedSecs: elapsedSecs, taskCompletedAt: completedAt1)
        try testContext.save()

        guard let zrr1 = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore)
        else { XCTFail(); return }
        XCTAssertEqual(elapsedSecs, zrr1.elapsedSecs)
        XCTAssertEqual(startedAt, zrr1.startedAt)

        // user removes ZRoutineRun (possibly from different device)

        zrr1.userRemoved = true
        try testContext.save()

        // user completes task (possibly from different device)

        try e2.logCompletion(testContext, mainStore: mainStore, startedAt: startedAt, elapsedSecs: elapsedSecs, taskCompletedAt: completedAt2)
        try testContext.save()

        guard let zrr2 = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore)
        else { XCTFail(); return }

        // ensure that ZRoutineRun has been restored from the userRemove (possibly on another device)
        XCTAssertFalse(zrr2.userRemoved)
    }
}
