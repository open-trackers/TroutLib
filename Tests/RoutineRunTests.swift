//
//  RoutineRunTests.swift
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

final class RoutineRunTests: TestBase {
    let routineArchiveID = UUID()
    let taskArchiveID1 = UUID()
    let taskArchiveID2 = UUID()

    let earlierAtStr = "2023-01-03T10:00:00Z"
    var earlierAt: Date!
    let startingAtStr = "2023-01-13T10:00:00Z"
    var startingAt: Date!
    let pausedAt1Str = "2023-01-13T11:00:00Z"
    var pausedAt1: Date!
    let resumingAt1Str = "2023-01-13T12:00:00Z"
    var resumingAt1: Date!
    let pausedAt2Str = "2023-01-13T13:00:00Z"
    var pausedAt2: Date!
    let quitAtStr = "2023-01-13T14:00:00Z"
    var quitAt: Date!

    let completedAt1Str = "2023-01-13T10:30:00Z"
    var completedAt1: Date!
    let completedAt2Str = "2023-01-13T12:30:00Z"
    var completedAt2: Date!
    var fromStartToPause1: TimeInterval!
    var fromStartToQuit: TimeInterval!
    var fromResume1ToQuit: TimeInterval!

    override func setUpWithError() throws {
        earlierAt = df.date(from: earlierAtStr)
        startingAt = df.date(from: startingAtStr)
        pausedAt1 = df.date(from: pausedAt1Str)
        resumingAt1 = df.date(from: resumingAt1Str)
        pausedAt2 = df.date(from: pausedAt2Str)
        quitAt = df.date(from: quitAtStr)
        completedAt1 = df.date(from: completedAt1Str)
        completedAt2 = df.date(from: completedAt2Str)

        fromStartToPause1 = startingAt.distance(to: pausedAt1)
        fromStartToQuit = startingAt.distance(to: quitAt)
        fromResume1ToQuit = resumingAt1.distance(to: quitAt)

        try super.setUpWithError()
    }

    func testStopAfterInadvertentStart() throws {
        let duration: Double = 1020

        // so earlier lastStartedAt and lastDuration should be preserved
        let c = MRoutine.create(testContext, userOrder: 5, name: "blink", archiveID: routineArchiveID)
        c.lastStartedAt = earlierAt
        c.lastDuration = duration
        try testContext.save()

        // inadvertent start by user
        guard let c1 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        _ = try c1.startOrResumeRun(testContext, now: startingAt)
        try testContext.save()

        // deliberate stop, with no tasks completed
        guard let c2 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        try c2.stopRun(startedOrResumedAt: startingAt, pause: false, now: quitAt)
        try testContext.save()

        XCTAssertEqual(earlierAt, c2.lastStartedAt)
        XCTAssertEqual(duration, c2.lastDuration)
        XCTAssertNil(c2.pausedAt)
    }

    func testPauseAfterInadvertentStart() throws {
        let duration: Double = 1020

        // so earlier lastStartedAt and lastDuration should be preserved
        let c = MRoutine.create(testContext, userOrder: 5, name: "blink", archiveID: routineArchiveID)
        c.lastStartedAt = earlierAt
        c.lastDuration = duration
        try testContext.save()

        // inadvertent start by user
        guard let c1 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        _ = try c1.startOrResumeRun(testContext, now: startingAt)
        try testContext.save()

        // deliberate stop, with no tasks completed
        guard let c2 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        try c2.stopRun(startedOrResumedAt: startingAt, pause: true, now: quitAt)
        try testContext.save()

        XCTAssertEqual(earlierAt, c2.lastStartedAt)
        XCTAssertEqual(duration, c2.lastDuration)
        XCTAssertNil(c2.pausedAt) // not actually paused!
    }

    func testInadvertentResume() throws {
        let c = MRoutine.create(testContext, userOrder: 5, name: "blink 0", archiveID: routineArchiveID)
        _ = MTask.create(testContext, routine: c, userOrder: 18, name: "bleh", archiveID: taskArchiveID1)
        try testContext.save()

        _ = try c.startOrResumeRun(testContext, now: startingAt)
        try testContext.save()

        // do some work
        guard let t2 = try MTask.get(testContext, routineArchiveID: routineArchiveID, archiveID: taskArchiveID1)
        else { XCTFail(); return }

        // this will set routine.lastStartedAt
        try t2.markDone(testContext, mainStore: mainStore, completedAt: completedAt1, routineStartedOrResumedAt: startingAt, logToHistory: false)
        try testContext.save()

        guard let c2 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        try c2.stopRun(startedOrResumedAt: startingAt, pause: true, now: pausedAt1)
        try testContext.save()

        // inadvertent resume
        guard let c3 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        _ = try c3.startOrResumeRun(testContext, now: resumingAt1)
        try testContext.save()

        // deliberate stop, with no additional tasks completed
        guard let c4 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        try c4.stopRun(startedOrResumedAt: resumingAt1, pause: false, now: resumingAt1 + 1)
        try testContext.save()

        XCTAssertEqual(startingAt, c4.lastStartedAt)
        XCTAssertEqual(3601, c4.lastDuration)
    }

    func testCannotStartTemplate() throws {
        let c = MRoutine.create(testContext, userOrder: 5, name: "blink", archiveID: routineArchiveID)
        c.isTemplate = true
        try testContext.save()
        XCTAssertThrowsError(try c.startOrResumeRun(testContext)) { error in
            XCTAssertEqual(TrackerError.invalidAction(msg: "Cannot start (or resume) a template."), error as! TrackerError)
        }
    }

    func testCannotResumeTemplate() throws {
        let c = MRoutine.create(testContext, userOrder: 5, name: "blink", archiveID: routineArchiveID)
        c.isTemplate = true
        c.pausedAt = pausedAt1
        try testContext.save()
        XCTAssertThrowsError(try c.startOrResumeRun(testContext)) { error in
            XCTAssertEqual(TrackerError.invalidAction(msg: "Cannot start (or resume) a template."), error as! TrackerError)
        }
    }

    func testStart() throws {
        let c = MRoutine.create(testContext, userOrder: 5, name: "blink 0", archiveID: routineArchiveID)
        XCTAssertNil(c.pausedAt)
        let t = MTask.create(testContext, routine: c, userOrder: 18, name: "bleh", archiveID: taskArchiveID1)
        t.lastCompletedAt = completedAt1
        try testContext.save()

        let actual = try c.startOrResumeRun(testContext, now: startingAt)
        try testContext.save()

        XCTAssertEqual(startingAt, actual)

        // ensure tasks are cleared
        guard let t2 = try MTask.get(testContext, routineArchiveID: routineArchiveID, archiveID: taskArchiveID1)
        else { XCTFail(); return }
        XCTAssertNil(t2.lastCompletedAt)

        // ensure pausedAt remains clear
        guard let c2 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        XCTAssertNil(c2.pausedAt)
        // XCTAssertNil(c2.resumedAt)
    }

    func testQuitAfterStart() throws {
        let c = MRoutine.create(testContext, userOrder: 5, name: "blink 0", archiveID: routineArchiveID)
        _ = MTask.create(testContext, routine: c, userOrder: 18, name: "bleh", archiveID: taskArchiveID1)
        try testContext.save()

        _ = try c.startOrResumeRun(testContext, now: startingAt)
        try testContext.save()

        // do some work
        guard let t2 = try MTask.get(testContext, routineArchiveID: routineArchiveID, archiveID: taskArchiveID1)
        else { XCTFail(); return }

        // this will set routine.lastStartedAt
        try t2.markDone(testContext, mainStore: mainStore, completedAt: completedAt1, routineStartedOrResumedAt: startingAt, logToHistory: false)
        try testContext.save()

        guard let c2 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        try c2.stopRun(startedOrResumedAt: startingAt, pause: false, now: quitAt)
        try testContext.save()

        guard let c3 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }

        // ensure duration is set
        // ensure routine.pausedAt is clear
        XCTAssertEqual(fromStartToQuit, c3.lastDuration)
        XCTAssertEqual(startingAt, c3.lastStartedAt)
        XCTAssertNil(c3.pausedAt)

        // TODO: ensure ZRoutineRun log record is created
    }

    func testPauseAfterStart() throws {
        let c = MRoutine.create(testContext, userOrder: 5, name: "blink 0", archiveID: routineArchiveID)
        _ = MTask.create(testContext, routine: c, userOrder: 18, name: "bleh", archiveID: taskArchiveID1)
        try testContext.save()

        _ = try c.startOrResumeRun(testContext, now: startingAt)
        try testContext.save()

        // do some work
        guard let t2 = try MTask.get(testContext, routineArchiveID: routineArchiveID, archiveID: taskArchiveID1)
        else { XCTFail(); return }

        // this will set routine.lastStartedAt
        try t2.markDone(testContext, mainStore: mainStore, completedAt: completedAt1, routineStartedOrResumedAt: startingAt, logToHistory: false)
        try testContext.save()

        guard let c2 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        try c2.stopRun(startedOrResumedAt: startingAt, pause: true, now: pausedAt1)
        try testContext.save()

        guard let c3 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }

        // ensure duration is set
        // ensure routine.pausedAt is clear
        XCTAssertEqual(3600, c3.lastDuration)
        XCTAssertEqual(startingAt, c3.lastStartedAt)
        XCTAssertEqual(pausedAt1, c3.pausedAt)

        // TODO: ensure ZRoutineRun log record is created
    }

    func testResume() throws {
        let c = MRoutine.create(testContext, userOrder: 5, name: "blink 0", archiveID: routineArchiveID)
        c.lastStartedAt = startingAt
        _ = MTask.create(testContext, routine: c, userOrder: 18, name: "bleh", archiveID: taskArchiveID1)
        try testContext.save()

        // do some work
        guard let t1 = try MTask.get(testContext, routineArchiveID: routineArchiveID, archiveID: taskArchiveID1)
        else { XCTFail(); return }
        // this will set routine.lastStartedAt
        try t1.markDone(testContext, mainStore: mainStore, completedAt: completedAt1, routineStartedOrResumedAt: startingAt, logToHistory: false)
        try testContext.save()

        guard let c2 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        try c2.stopRun(startedOrResumedAt: startingAt, pause: true, now: pausedAt1)
        try testContext.save()

        // resume
        guard let c3 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        let actual = try c3.startOrResumeRun(testContext, now: resumingAt1)
        try testContext.save()
        XCTAssertEqual(resumingAt1, actual)

        // ensure tasks have NOT been cleared
        guard let t2 = try MTask.get(testContext, routineArchiveID: routineArchiveID, archiveID: taskArchiveID1)
        else { XCTFail(); return }
        XCTAssertNotNil(t2.lastCompletedAt)

        // validate resumed state
        guard let c4 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        XCTAssertEqual(pausedAt1, c4.pausedAt)
        XCTAssertEqual(startingAt, c4.lastStartedAt) // shouldn't have changed
        XCTAssertEqual(3600, c4.lastDuration) // shouldn't have changed
    }

    func testQuitAfterResume() throws {
        let c = MRoutine.create(testContext, userOrder: 5, name: "blink 0", archiveID: routineArchiveID)
        c.lastStartedAt = startingAt
        _ = MTask.create(testContext, routine: c, userOrder: 18, name: "bleh", archiveID: taskArchiveID1)
        try testContext.save()

        // do some work
        guard let t1 = try MTask.get(testContext, routineArchiveID: routineArchiveID, archiveID: taskArchiveID1)
        else { XCTFail(); return }
        // this will set routine.lastStartedAt
        try t1.markDone(testContext, mainStore: mainStore, completedAt: completedAt1, routineStartedOrResumedAt: startingAt, logToHistory: false)
        try testContext.save()

        guard let c2 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        try c2.stopRun(startedOrResumedAt: startingAt, pause: true, now: pausedAt1)
        try testContext.save()

        // resume
        guard let c3 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        let actual = try c3.startOrResumeRun(testContext, now: resumingAt1)
        try testContext.save()
        XCTAssertEqual(resumingAt1, actual)

        // stop and quit
        guard let c4 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        try c4.stopRun(startedOrResumedAt: resumingAt1, pause: false, now: quitAt)
        try testContext.save()

        guard let c5 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }

        let expectedDuration = fromStartToPause1 + fromResume1ToQuit

        // ensure duration has advanced, including total duration since startingAt (14,400)
        // ensure routine.pausedAt is clear
        XCTAssertEqual(expectedDuration, c5.lastDuration)
        XCTAssertEqual(startingAt, c5.lastStartedAt)
        XCTAssertNil(c5.pausedAt)

        // TODO: ensure ZRoutineRun log record is created
    }

    func testTaskBeforeAndAfterResume() throws {
        // ensure that lastStartedAt isn't messed with

        let c = MRoutine.create(testContext, userOrder: 5, name: "blink 0", archiveID: routineArchiveID)
        c.lastStartedAt = startingAt
        _ = MTask.create(testContext, routine: c, userOrder: 18, name: "bleh", archiveID: taskArchiveID1)
        _ = MTask.create(testContext, routine: c, userOrder: 19, name: "blort", archiveID: taskArchiveID2)
        try testContext.save()

        // do some work on first task
        guard let t1 = try MTask.get(testContext, routineArchiveID: routineArchiveID, archiveID: taskArchiveID1)
        else { XCTFail(); return }
        // this will set routine.lastStartedAt
        try t1.markDone(testContext, mainStore: mainStore, completedAt: completedAt1, routineStartedOrResumedAt: startingAt, logToHistory: false)
        try testContext.save()

        guard let c2 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        try c2.stopRun(startedOrResumedAt: startingAt, pause: true, now: pausedAt1)
        try testContext.save()

        // resume
        guard let c3 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        let actual = try c3.startOrResumeRun(testContext, now: resumingAt1)
        try testContext.save()
        XCTAssertEqual(resumingAt1, actual)

        guard let t2 = try MTask.get(testContext, routineArchiveID: routineArchiveID, archiveID: taskArchiveID2)
        else { XCTFail(); return }
        try t2.markDone(testContext, mainStore: mainStore, completedAt: completedAt2, routineStartedOrResumedAt: resumingAt1, logToHistory: false)
        try testContext.save()

        // stop and quit
        guard let c4 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }
        try c4.stopRun(startedOrResumedAt: resumingAt1, pause: false, now: quitAt)
        try testContext.save()

        guard let c5 = try MRoutine.get(testContext, archiveID: routineArchiveID)
        else { XCTFail(); return }

        let expectedDuration = fromStartToPause1 + fromResume1ToQuit

        // ensure duration has advanced, including total duration since startingAt (14,400)
        // ensure routine.pausedAt is clear
        XCTAssertEqual(expectedDuration, c5.lastDuration)
        XCTAssertEqual(startingAt, c5.lastStartedAt)
        XCTAssertNil(c5.pausedAt)
    }
}
