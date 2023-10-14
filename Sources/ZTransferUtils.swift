//
//  ZTransferUtils.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import os

import TrackerLib

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                            category: "ZTransfer")

/// Transfers all 'Z' records in .main store to .archive store.
/// Preserves 'fresh' zRoutines in .main store no older than thresholdSecs. Deletes those 'stale' ones earlier.
/// Safe to run on a background context.
/// NOTE: does NOT save context
public func transferToArchive(_ context: NSManagedObjectContext,
                              mainStore: NSPersistentStore,
                              archiveStore: NSPersistentStore,
                              thresholdSecs: TimeInterval,
                              now: Date = Date.now) throws
{
    logger.debug("\(#function)")

    let zRoutines = try deepCopy(context, fromStore: mainStore, toStore: archiveStore)

    let staleRecords = zRoutines.filter { !$0.isFresh(context, thresholdSecs: thresholdSecs, now: now) }

    // rely on cascading delete to remove children
    staleRecords.forEach { context.delete($0) }
}

/// Deep copy of all routines and their children from the source store to specified destination store
/// Returns list of ZRoutines in fromStore that have been copied.
/// Does not delete any records.
/// Safe to run on a background context.
/// Does NOT save context.
func deepCopy(_ context: NSManagedObjectContext,
              fromStore srcStore: NSPersistentStore,
              toStore dstStore: NSPersistentStore) throws -> [ZRoutine]
{
    logger.debug("\(#function)")
    var copiedZRoutines = [ZRoutine]()

    try context.fetcher(inStore: srcStore) { (sRoutine: ZRoutine) in

        let dRoutine = try sRoutine.shallowCopy(context, toStore: dstStore)

        let routinePred = ZTask.getPredicate(zRoutine: sRoutine)

        // will need dMTask for creating dMTaskRun
        var dMTaskDict: [UUID: ZTask] = [:]
        var dMFieldDict: [UUID: ZField] = [:]

        try context.fetcher(predicate: routinePred, inStore: srcStore) { (sTask: ZTask) in
            let dMTask = try sTask.shallowCopy(context, dstRoutine: dRoutine, toStore: dstStore)

            if let uuid = dMTask.taskArchiveID {
                dMTaskDict[uuid] = dMTask
            } else {
                logger.error("Missing archiveID for zTask \(sTask.wrappedName)")
            }

            logger.debug("Copied zTask \(sTask.wrappedName)")

            let taskPred = ZField.getPredicate(zTask: sTask)

            try context.fetcher(predicate: taskPred, inStore: srcStore) { (sField: ZField) in

                let dField = try sField.shallowCopy(context, dstTask: dMTask, toStore: dstStore)

                if let uuid = dField.fieldArchiveID {
                    dMFieldDict[uuid] = dField
                } else {
                    logger.error("Missing archiveID for zField \(sField.wrappedName)")
                }

                return true
            }

            return true
        }

        // NOTE: including even those ZRoutineRun records with userRemoved==1, as we need to reflect
        // removed records in the archive (which may have been previously copied as userRemoved=0)
        try context.fetcher(predicate: routinePred, inStore: srcStore) { (sRoutineRun: ZRoutineRun) in

            let dRoutineRun = try sRoutineRun.shallowCopy(context, dstRoutine: dRoutine, toStore: dstStore)

            let routineRunPred = ZTaskRun.getPredicate(zRoutineRun: sRoutineRun)

            // NOTE: including even those ZTaskRun records with userRemoved==1, as we need to reflect
            // removed records in the archive (which may have been previously copied as userRemoved=0)
            try context.fetcher(predicate: routineRunPred, inStore: srcStore) { (sTaskRun: ZTaskRun) in

                guard let taskArchiveID = sTaskRun.zTask?.taskArchiveID,
                      let dTask = dMTaskDict[taskArchiveID]
                else {
                    logger.error("Could not determine taskArchiveID to obtain destination task")
                    return true
                }

                let dTaskRun = try sTaskRun.shallowCopy(context, dstRoutineRun: dRoutineRun, dstTask: dTask, toStore: dstStore)

                logger.debug("Copied zTaskRun \(sTaskRun.zTask?.name ?? "") completedAt=\(String(describing: sTaskRun.completedAt))")

                let taskRunPred = ZFieldRun.getPredicate(zTaskRun: sTaskRun)

                try context.fetcher(predicate: taskRunPred, inStore: srcStore) { (sFieldRun: ZFieldRun) in

                    guard let fieldArchiveID = sFieldRun.zField?.fieldArchiveID,
                          let dField = dMFieldDict[fieldArchiveID]
                    else {
                        logger.error("Could not determine fieldArchiveID to obtain destination field")
                        return true
                    }

                    _ = try sFieldRun.shallowCopy(context, dstTaskRun: dTaskRun, dstField: dField, toStore: dstStore)
                    return true
                }

                return true
            }

            logger.debug("Copied zRoutineRun \(sRoutine.wrappedName) startedAt=\(String(describing: sRoutineRun.startedAt))")
            return true
        }

        copiedZRoutines.append(sRoutine)
        logger.debug("Copied zRoutine \(sRoutine.wrappedName)")

        return true
    }

    return copiedZRoutines
}
