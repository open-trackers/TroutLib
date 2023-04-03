//
//  MRoutine-nextIncomplete.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension MRoutine {
    var taskPredicate: NSPredicate {
        MTask.getPredicate(routine: self)
    }

    var incompletePredicate: NSPredicate {
        NSCompoundPredicate(andPredicateWithSubpredicates: [
            taskPredicate,
            NSPredicate(format: "lastCompletedAt = Nil"),
        ])
    }

    func getNextIncomplete(_ context: NSManagedObjectContext, from userOrder: Int16? = nil) throws -> NSManagedObjectID? {
        let req = NSFetchRequest<MTask>(entityName: "MTask")
        req.sortDescriptors = MTask.byUserOrder()
        req.returnsObjectsAsFaults = false
        req.fetchLimit = 1

        do {
            if let _userOrder = userOrder {
                // print("\(#function) next trailing")
                req.predicate = nextTrailing(from: _userOrder)
                if let next = try (context.fetch(req) as [MTask]).first {
                    // print("\(#function) next trailing found \(next.uriRepresentationSuffix ?? "")")
                    return next.objectID
                }

                // print("\(#function) next leading")
                req.predicate = nextLeading(to: _userOrder)
                if let next = try (context.fetch(req) as [MTask]).first {
                    // print("\(#function) next leading found \(next.uriRepresentationSuffix ?? "")")
                    return next.objectID
                }
            } else {
                // print("\(#function) start from beginning")
                // start from beginning
                req.predicate = incompletePredicate
                if let next = try (context.fetch(req) as [MTask]).first {
                    // print("\(#function) from beginning found \(next.uriRepresentationSuffix ?? "")")
                    return next.objectID
                }
            }
        } catch {
            throw TrackerError.fetchError(msg: error.localizedDescription)
        }

        return nil
    }

    internal func nextTrailing(from userOrder: Int16) -> NSPredicate {
        NSCompoundPredicate(andPredicateWithSubpredicates: [
            incompletePredicate,
            NSPredicate(format: "userOrder > %d", userOrder),
        ])
    }

    internal func nextLeading(to userOrder: Int16) -> NSPredicate {
        NSCompoundPredicate(andPredicateWithSubpredicates: [
            incompletePredicate,
            NSPredicate(format: "userOrder < %d", userOrder),
        ])
    }
}
