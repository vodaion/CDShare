//
//  CoreDataSharingHandler.swift
//  CDShare
//
//  Created by IonVoda on 12/12/2018.
//  Copyright © 2018 IonVoda. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public extension NSNotification.Name {
    static let CoreDataShareDidSave = NSNotification.Name("CoreDataSharingNotification.InjectedDataInMemory")
}

public class CoreDataShare {
    private let configuration: CoreDataShareConfiguration
    private var watcher: FolderWatcher!
    private var viewContext: NSManagedObjectContext

    public var sharedInScopeEntityNames: [String] = []

    public init(configuration: CoreDataShareConfiguration, viewContext: NSManagedObjectContext) throws {
        self.configuration = configuration
        self.viewContext = viewContext
        let readingAppName = configuration.readingEndpoint.applicationName.identifier
        let folderURL = configuration.groupIdentifier.folderURL.appendingPathComponent(readingAppName)
        self.watcher = try FolderWatcher(folderURL) { [unowned self] in
            DispatchQueue.main.async {
                self.updateContextData(folderURL, context: viewContext)
            }
        }

        let writtingContext = configuration.writingEndpoint.contextSource
        let selector = #selector(CoreDataShare.contextDidSave)
        NotificationCenter.default.addObserver(self, selector: selector, name: .NSManagedObjectContextDidSave, object: writtingContext)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextDidSave, object: configuration.writingEndpoint.contextSource)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    public func clearContextFolder() {
        let folderURL = watcher.folderURL
        do {
            try FileManager
                .default
                .contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
                .forEach { try FileManager.default.removeItem(at: $0) }
        } catch let error as NSError {
            print("Error reading contents of folder: \(folderURL.absoluteString) with error: \(error.localizedDescription)")
        }
    }

    private func updateContextData(_ folderURL: URL, context: NSManagedObjectContext) {
        do {
            let properties = [URLResourceKey.addedToDirectoryDateKey]
            let files = try FileManager
                .default
                .contentsOfDirectory(at: folderURL, includingPropertiesForKeys: properties, options: .skipsSubdirectoryDescendants)
                // Files with names that contains ".dat.nosync" are created automaticaly by OS and should be skiped.
                .filter{ $0.lastPathComponent.contains(".dat.nosync") == false }

            guard files.isEmpty == false else {
                return
            }
            let addDatesAndURLs: [(date: Date, url: URL)] = files.compactMap {
                var addedDateOp: AnyObject?
                try? ($0 as NSURL).getResourceValue(&addedDateOp, forKey: URLResourceKey.addedToDirectoryDateKey)
                guard let addedDate = addedDateOp as? Date else {
                    return nil
                }
                return (addedDate, $0)
            }
            let sortedFileURLs = addDatesAndURLs
                .sorted { $0.date.compare($1.date) == .orderedAscending ? true : false }
                .map { $0.url }

            configuration.readingEndpoint.contextSource.performAndWait { [unowned self] in
                let importNotification = self.notification(fromURLs: sortedFileURLs)
                self.configuration.readingEndpoint.contextSource.mergeChanges(fromContextDidSave: importNotification)
                context.mergeChanges(fromContextDidSave: importNotification)

                for fileURL in sortedFileURLs {
                    do {
                        try FileManager.default.removeItem(at: fileURL)
                    } catch let error as NSError {
                        print("Error deleting file: \( fileURL.absoluteString) with error: \(error.localizedDescription)")
                    }
                }
                try? context.save()
                NotificationCenter.default.post(name: .CoreDataShareDidSave, object: nil)
            }
        } catch let error as NSError {
            print("Error reading contents of folder: \(folderURL) with error: %@", error.localizedDescription)
        }
    }

    @objc private func contextDidSave(_ notification: Notification) {
        let infoToSave = dictionaryFrom(notification)
        guard infoToSave.allKeys.isEmpty == false  else {
            return
        }
        configuration.writingEndpoint.applicationNames
            .compactMap { configuration.groupIdentifier.folderURL.appendingPathComponent("\($0.identifier)") }
            .forEach {
                do {
                    try FileManager.default.createDirectory(at: $0, withIntermediateDirectories: true, attributes: nil)

                    let fileName = UUID().uuidString
                    let filenameURL = $0.appendingPathComponent(fileName)
                    infoToSave.write(to: filenameURL, atomically: true)
                } catch let error as NSError {
                    print("Error when creating folder: \($0.absoluteString) with error: \(error.localizedDescription)")
                }
        }
    }

    private func dictionaryFrom(_ notification: Notification) -> NSDictionary {
        let userInfo: [String:[String]] = [NSInsertedObjectsKey, NSDeletedObjectsKey, NSUpdatedObjectsKey]
            .reduce([:]) { result, key in
                let elements = notification.userInfo?[key] as? Set<NSManagedObject>
                let objectIDsfullPathsOp: [String]? = elements?.compactMap {
                    guard let name = $0.entity.name, sharedInScopeEntityNames.contains(name) == true else {
                        return nil
                    }
                    return $0.objectID.uriRepresentation().absoluteString
                }
                guard let objectIDsfullPaths = objectIDsfullPathsOp, objectIDsfullPaths.isEmpty == false else {
                    return result
                }
                return result.merging([key: objectIDsfullPaths]) { (_, new) in new }
        }
        return userInfo as NSDictionary
    }

    private func notification(fromURLs: [URL]) -> Notification {
        let userInfo: [String: [NSManagedObjectID]] = fromURLs
            .compactMap { NSDictionary(contentsOf: $0) }
            .reduce([:]) { result, element in result.merging(userInfoTransforming(element)) { (_, new) in new} }
            .normalize()
        let notification = Notification(name: .NSManagedObjectContextDidSave, object: viewContext, userInfo: userInfo)
        return notification
    }

    private func userInfoTransforming(_ dictionary: NSDictionary) -> [String: [NSManagedObjectID]] {
        let userInfo: [String: [NSManagedObjectID]] = dictionary
            .reduce([:]) { result, element in
                guard
                    let key = element.key as? String,
                    let value = element.value as? [String] else {
                        return result
                }
                let objectIDs: [NSManagedObjectID] = value
                    .compactMap { URL(string: $0) }
                    .compactMap { viewContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: $0) }
                return result.merging([key: objectIDs]) { (_, new) in new }
        }
        return userInfo
    }
}
