//
//  ShallowCopyTests.swift
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

final class ShallowCopyTests: TestBase {
    let routineArchiveID = UUID()
    let taskArchiveID = UUID()
    let fieldArchiveID = UUID()

    let createdAt1Str = "2023-01-01T05:00:00Z"
    var createdAt1: Date!
    let createdAt2Str = "2023-01-02T05:00:00Z"
    var createdAt2: Date!
    let createdAt3Str = "2023-01-03T05:00:00Z"
    var createdAt3: Date!
    let createdAt4Str = "2023-01-04T05:00:00Z"
    var createdAt4: Date!
    let createdAt5Str = "2023-01-05T05:00:00Z"
    var createdAt5: Date!

    override func setUpWithError() throws {
        try super.setUpWithError()

        createdAt1 = df.date(from: createdAt1Str)
        createdAt2 = df.date(from: createdAt2Str)
        createdAt3 = df.date(from: createdAt3Str)
        createdAt4 = df.date(from: createdAt4Str)
        createdAt5 = df.date(from: createdAt5Str)
    }

    func testReadOnly() throws {
        XCTAssertFalse(mainStore.isReadOnly)
        XCTAssertFalse(archiveStore.isReadOnly)
    }

    func testRoutine() throws {
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", createdAt: createdAt1, toStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))

        _ = try sr.shallowCopy(testContext, toStore: archiveStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        let dr: ZRoutine? = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        XCTAssertNotNil(dr)
        XCTAssertEqual(createdAt1, dr?.createdAt)
    }

    func testRoutineWithTaskAndField() throws {
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", createdAt: createdAt1, toStore: mainStore)
        let se = ZTask.create(testContext, zRoutine: sr, taskArchiveID: taskArchiveID, taskName: "bleh", createdAt: createdAt2, toStore: mainStore)
        let sf = ZField.create(testContext, zTask: se, fieldArchiveID: fieldArchiveID, createdAt: createdAt3, toStore: mainStore)
        sf.name = "blort"
        sf.unitsSuffix = "kg"
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZField.get(testContext, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: mainStore))

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZField.get(testContext, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: archiveStore))

        // routine needs to get to archive first
        _ = try sr.shallowCopy(testContext, toStore: archiveStore)
        try testContext.save()
        guard let dr = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        // now the task copy
        let de = try se.shallowCopy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()

        // now the field copy
        _ = try sf.shallowCopy(testContext, dstTask: de, toStore: archiveStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZField.get(testContext, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZField.get(testContext, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: archiveStore))

        let dc: ZRoutine? = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        XCTAssertNotNil(dc)
        XCTAssertEqual(createdAt1, dc?.createdAt)
        let ds: ZTask? = try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: archiveStore)
        XCTAssertNotNil(ds)
        XCTAssertEqual(createdAt2, ds?.createdAt)
        let df: ZField? = try ZField.get(testContext, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: archiveStore)
        XCTAssertNotNil(df)
        XCTAssertEqual(createdAt3, df?.createdAt)
        XCTAssertEqual("kg", df?.unitsSuffix)
    }

    func testRoutineWithRoutineRun() throws {
        let startedAt = Date()
        let elapsedSecs: TimeInterval = 30.0
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", toStore: mainStore)
        let su = ZRoutineRun.create(testContext, zRoutine: sr, startedAt: startedAt, elapsedSecs: elapsedSecs, toStore: mainStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))

        XCTAssertNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))

        // routine needs to get to archive first
        _ = try sr.shallowCopy(testContext, toStore: archiveStore)
        try testContext.save()
        guard let dr = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        // now the routineRun copy
        _ = try su.shallowCopy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
    }

    func testRoutineWithTaskAndTaskRunAndFieldRun() throws {
        let completedAt = Date()
        let startedAt = Date()
        let elapsedSecs: TimeInterval = 30.0
        let sr = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", createdAt: createdAt1, toStore: mainStore)
        let se = ZTask.create(testContext, zRoutine: sr, taskArchiveID: taskArchiveID, taskName: "bleh", createdAt: createdAt2, toStore: mainStore)
        let srr = ZRoutineRun.create(testContext, zRoutine: sr, startedAt: startedAt, elapsedSecs: elapsedSecs, createdAt: createdAt3, toStore: mainStore)
        let str = ZTaskRun.create(testContext, zRoutineRun: srr, zTask: se, completedAt: completedAt, createdAt: createdAt4, toStore: mainStore)
        let sf = ZField.create(testContext, zTask: se, fieldArchiveID: fieldArchiveID, fieldName: "blort", createdAt: createdAt3, toStore: mainStore)
        let sfr = ZFieldRun.create(testContext, zTaskRun: str, zField: sf, createdAt: createdAt5, toStore: mainStore)
        sfr.value = "booya"
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID, completedAt: completedAt, inStore: mainStore))
        XCTAssertNotNil(try ZField.get(testContext, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZFieldRun.get(testContext, fieldArchiveID: fieldArchiveID, completedAt: completedAt, inStore: mainStore))

        // routine needs to get to archive first
        _ = try sr.shallowCopy(testContext, toStore: archiveStore)
        try testContext.save()
        guard let dr = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        // and routineRun too
        _ = try srr.shallowCopy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()
        guard let drr = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore)
        else { XCTFail(); return }

        // and task too
        _ = try se.shallowCopy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()
        guard let de = try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        // and copy the task run
        _ = try str.shallowCopy(testContext, dstRoutineRun: drr, dstTask: de, toStore: archiveStore)
        try testContext.save()
        guard let dtr = try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID, completedAt: completedAt, inStore: archiveStore)
        else { XCTFail(); return }
        try testContext.save()

        // and field too
        _ = try sf.shallowCopy(testContext, dstTask: de, toStore: archiveStore)
        try testContext.save()
        guard let df = try ZField.get(testContext, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        // and copy the field run
        _ = try sfr.shallowCopy(testContext, dstTaskRun: dtr, dstField: df, toStore: archiveStore)
        try testContext.save()

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: mainStore))
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID, completedAt: completedAt, inStore: mainStore))
        XCTAssertNotNil(try ZField.get(testContext, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: mainStore))
        XCTAssertNotNil(try ZFieldRun.get(testContext, fieldArchiveID: fieldArchiveID, completedAt: completedAt, inStore: mainStore))

        XCTAssertNotNil(try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore))
        XCTAssertNotNil(try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID, completedAt: completedAt, inStore: archiveStore))
        XCTAssertNotNil(try ZField.get(testContext, taskArchiveID: taskArchiveID, fieldArchiveID: fieldArchiveID, inStore: archiveStore))
        XCTAssertNotNil(try ZFieldRun.get(testContext, fieldArchiveID: fieldArchiveID, completedAt: completedAt, inStore: archiveStore))

        let dc: ZRoutine? = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        XCTAssertNotNil(dc)
        XCTAssertEqual(createdAt1, dc?.createdAt)
        let ds: ZTask? = try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: archiveStore)
        XCTAssertNotNil(ds)
        XCTAssertEqual(createdAt2, ds?.createdAt)
        let ddr2: ZRoutineRun? = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore)
        XCTAssertNotNil(ddr2)
        XCTAssertEqual(createdAt3, ddr2?.createdAt)
        let dsr: ZTaskRun? = try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID, completedAt: completedAt, inStore: archiveStore)
        XCTAssertNotNil(dsr)
        XCTAssertEqual(createdAt4, dsr?.createdAt)
        let dsf: ZFieldRun? = try ZFieldRun.get(testContext, fieldArchiveID: fieldArchiveID, completedAt: completedAt, inStore: archiveStore)
        XCTAssertNotNil(dsf)
        XCTAssertEqual(createdAt5, dsf?.createdAt)
    }

    func testTaskRunIncludesUserRemoved() throws {
        let startedAt = Date()
        let completedAt = startedAt.addingTimeInterval(1000)
        let sc = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", createdAt: createdAt1, toStore: mainStore)
        let ss = ZTask.create(testContext, zRoutine: sc, taskArchiveID: taskArchiveID, taskName: "bleh", createdAt: createdAt2, toStore: mainStore)
        let sdr = ZRoutineRun.create(testContext, zRoutine: sc, startedAt: startedAt, createdAt: createdAt3, toStore: mainStore)
        let ssr = ZTaskRun.create(testContext, zRoutineRun: sdr, zTask: ss, completedAt: completedAt, createdAt: createdAt4, toStore: mainStore)
        ssr.userRemoved = true
        try testContext.save()

        _ = try sc.shallowCopy(testContext, toStore: archiveStore)
        try testContext.save()
        guard let dr = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        _ = try sdr.shallowCopy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()
        guard let ddr = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore)
        else { XCTFail(); return }

        _ = try ss.shallowCopy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()
        guard let de = try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        _ = try ssr.shallowCopy(testContext, dstRoutineRun: ddr, dstTask: de, toStore: archiveStore)
        try testContext.save()

        let dsr: ZTaskRun? = try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID, completedAt: completedAt, inStore: archiveStore)
        XCTAssertNotNil(dsr)
        XCTAssertTrue(dsr!.userRemoved)
    }

    func testRoutineRunIncludesUserRemoved() throws {
        let startedAt = Date()
        let completedAt = startedAt.addingTimeInterval(1000)
        let sc = ZRoutine.create(testContext, routineArchiveID: routineArchiveID, routineName: "blah", createdAt: createdAt1, toStore: mainStore)
        let ss = ZTask.create(testContext, zRoutine: sc, taskArchiveID: taskArchiveID, taskName: "bleh", createdAt: createdAt2, toStore: mainStore)
        let sdr = ZRoutineRun.create(testContext, zRoutine: sc, startedAt: startedAt, createdAt: createdAt3, toStore: mainStore)
        let ssr = ZTaskRun.create(testContext, zRoutineRun: sdr, zTask: ss, completedAt: completedAt, createdAt: createdAt4, toStore: mainStore)

        sdr.userRemoved = true // remove the routineRun
        try testContext.save()

        _ = try sc.shallowCopy(testContext, toStore: archiveStore)
        try testContext.save()
        guard let dr = try ZRoutine.get(testContext, routineArchiveID: routineArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        _ = try sdr.shallowCopy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()
        guard let ddr = try ZRoutineRun.get(testContext, routineArchiveID: routineArchiveID, startedAt: startedAt, inStore: archiveStore)
        else { XCTFail(); return }
        XCTAssertTrue(ddr.userRemoved)

        _ = try ss.shallowCopy(testContext, dstRoutine: dr, toStore: archiveStore)
        try testContext.save()
        guard let de = try ZTask.get(testContext, routineArchiveID: routineArchiveID, taskArchiveID: taskArchiveID, inStore: archiveStore)
        else { XCTFail(); return }

        _ = try ssr.shallowCopy(testContext, dstRoutineRun: ddr, dstTask: de, toStore: archiveStore)
        try testContext.save()

        let dsr: ZTaskRun? = try ZTaskRun.get(testContext, taskArchiveID: taskArchiveID, completedAt: completedAt, inStore: archiveStore)
        XCTAssertNotNil(dsr)
        XCTAssertFalse(dsr!.userRemoved) // because only the parent routineRun has been removed
    }
}
