//
//  Export-utils.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

#if !os(watchOS)
    public func troutCreateZipArchive(_ context: NSManagedObjectContext,
                                      mainStore: NSPersistentStore,
                                      archiveStore: NSPersistentStore,
                                      format: ExportFormat = .CSV) throws -> Data?
    {
        let entries: [(String, Data)] = try [
            makeDelimFile(AppSetting.self, context, format: format, inStore: mainStore),
            makeDelimFile(MRoutine.self, context, format: format, inStore: mainStore),
            makeDelimFile(MTask.self, context, format: format, inStore: mainStore),
            makeDelimFile(MTaskGroup.self, context, format: format, inStore: mainStore),
            makeDelimFile(MFieldInt16.self, context, format: format, inStore: mainStore),
            makeDelimFile(MFieldBool.self, context, format: format, inStore: mainStore),

            makeDelimFile(ZRoutine.self, context, format: format, inStore: archiveStore),
            makeDelimFile(ZRoutineRun.self, context, format: format, inStore: archiveStore),
            makeDelimFile(ZTask.self, context, format: format, inStore: archiveStore),
            makeDelimFile(ZTaskRun.self, context, format: format, inStore: archiveStore),
        ]

        return try createZipArchive(context, entries: entries)
    }
#endif
