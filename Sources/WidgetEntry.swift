//
//  WidgetEntry.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import SwiftUI
import WidgetKit

import Collections

public struct WidgetEntry: TimelineEntry, Codable {
    public struct Pair: Codable {
        public let color: Color
        public let value: Float

        public init(_ color: Color, _ value: Float) {
            self.color = color
            self.value = value
        }
    }

    public let date: Date
    public let name: String
    public let timeInterval: TimeInterval
    public let pairs: [Pair]

    public init(date: Date = Date.now,
                name: String,
                timeInterval: TimeInterval,
                pairs: [Pair] = [])
    {
        self.date = date
        self.name = name
        self.timeInterval = timeInterval
        self.pairs = pairs
    }
}

public extension UserDefaults {
    internal static let appGroupSuiteName = "group.org.openalloc.trout"
    internal static let widgetEntryKey = "widgetEntry"

    static let appGroup = UserDefaults(suiteName: appGroupSuiteName)!

    func get() -> WidgetEntry? {
        guard let data = data(forKey: Self.widgetEntryKey) else { return nil }
        return try? JSONDecoder().decode(WidgetEntry.self, from: data)
    }

    func set(_ entry: WidgetEntry) {
        let data = try? JSONEncoder().encode(entry)
        set(data, forKey: Self.widgetEntryKey)
    }
}

public extension WidgetEntry {
    // Refresh widget with the latest data.
    // NOTE: does NOT save context (if AppSetting is created)
    static func refresh(_ context: NSManagedObjectContext,
                        now: Date = Date.now,
                        reload: Bool,
                        defaultColor: Color = .clear) throws
    {
        let sort = MRoutine.byLastStartedAt(ascending: false)

        // obtain most recent routine
        guard let routine = try MRoutine.getFirst(context, sort: sort),
              let lastStartedAt = routine.lastStartedAt
        else { return }

        let lastEnded = lastStartedAt.addingTimeInterval(routine.lastDuration)

        let timeInterval = now.timeIntervalSince(lastEnded)

        var colorSet = OrderedSet<Color>()
        try context.fetcher(sortDescriptors: sort) { (routine: MRoutine) in
            let color = routine.getColor() ?? defaultColor
            colorSet.append(color)
            return true
        }

        let pairs: [WidgetEntry.Pair] = {
            let colorCount = colorSet.count
            guard colorCount > 0 else { return [] }
            return colorSet.reduce(into: []) { array, color in
                let pair = WidgetEntry.Pair(color, 1 / Float(colorCount))
                array.append(pair)
            }
        }()

        refresh(timeInterval: timeInterval, pairs: pairs, reload: reload)
    }

    internal static func refresh(timeInterval: TimeInterval,
                                 pairs: [WidgetEntry.Pair],
                                 now: Date = Date.now,
                                 reload: Bool)
    {
        print("REFRESH target \(timeInterval)")
        let entry = WidgetEntry(date: now,
                                name: "TODO",
                                timeInterval: timeInterval,
                                pairs: pairs)
        UserDefaults.appGroup.set(entry)

        if reload {
            print("RELOADING ALL TIMELINES ##############################################")
            UserDefaults.appGroup.synchronize() // ensure new values written to disk
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
