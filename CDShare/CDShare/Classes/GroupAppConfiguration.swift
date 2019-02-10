//
//  GroupAppConfiguration.swift
//  CDShare
//
//  Created by IonVoda on 12/12/2018.
//  Copyright © 2018 IonVoda. All rights reserved.
//

import Foundation
import CoreData

public protocol ApplicationIdentifier {
    var identifier: String { get }
}

public protocol ApplicationGroupInfo {
    var group: ApplicationIdentifier { get }
    var reading: ApplicationIdentifier { get }
    var writing: [ApplicationIdentifier] { get }
}

public protocol CoreDataGroupInfo {
    var groupIdentifier: String { get }
    var folderURL: URL { get }
}

private struct CoreDataGroupInfoModel: CoreDataGroupInfo {
    var groupIdentifier: String
    var folderURL: URL
}

public class CoreDataShareConfiguration {
    public enum GroupAppConfigurationError: Error {
        case noGroup(with: String)
    }

    public let groupIdentifier: CoreDataGroupInfo

    public let readingEndpoint: ReadingEndpoint
    public let writingEndpoint: WritingEndpoint

    public init(_ groupInfo: ApplicationGroupInfo, readingContext: NSManagedObjectContext, writingContext: NSManagedObjectContext) throws {
        let groupIdentifier = groupInfo.group.identifier
        let readingEndpoint = groupInfo.reading
        let writingEndpoints = groupInfo.writing

        guard let groupFolder = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier) else {
            throw GroupAppConfigurationError.noGroup(with: groupIdentifier)
        }

        let contextFolder = groupFolder.appendingPathComponent("CDShareContextFolder", isDirectory: true)
        self.groupIdentifier = CoreDataGroupInfoModel(groupIdentifier: groupIdentifier, folderURL: contextFolder)
        self.readingEndpoint = ReadingEndpoint(applicationName: readingEndpoint, contextSource: readingContext)
        self.writingEndpoint = WritingEndpoint(applicationNames: writingEndpoints, contextSource: writingContext)
    }
}
