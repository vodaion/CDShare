//
//  Dictionary+CoreData.swift
//  CDShare
//
//  Created by IonVoda on 12/12/2018.
//  Copyright © 2018 IonVoda. All rights reserved.
//

import Foundation
import CoreData

internal extension Dictionary where Key == String, Value == [NSManagedObjectID] {
    func normalize() -> [String: [NSManagedObjectID]] {
        let updatedObjects = self[NSUpdatedObjectsKey]
        let insertedObjects = self[NSInsertedObjectsKey]
        let deletedObjects = self[NSDeletedObjectsKey]

        var userInfo: [String: [NSManagedObjectID]] = [:]
        let inserted = insertedObjects?.compactMap { deletedObjects?.contains($0) == true ? nil : $0 }
        if let inserted = inserted, inserted.count > 0 {
            userInfo[NSInsertedObjectsKey] = inserted
        }

        let deleted = deletedObjects?.compactMap { insertedObjects?.contains($0) == true ? nil : $0 }
        if let deleted = deleted, deleted.count > 0 {
            userInfo[NSDeletedObjectsKey] = deleted
        }

        let updated = updatedObjects?.compactMap { deletedObjects?.contains($0) == true ? nil : $0 }
        if let updated = updated, updated.count > 0 {
            userInfo[NSUpdatedObjectsKey] = updated
        }

        return userInfo
    }
}
