//
//  FolderWatcher.swift
//  CDShare
//
//  Created by IonVoda on 12/12/2018.
//  Copyright © 2018 IonVoda. All rights reserved.
//

import Foundation

internal class FolderWatcher {
    private var source: DispatchSourceFileSystemObject
    private var queue: DispatchQueue?
    private var sourceFolderURL: URL

    var folderURL: URL {
        return sourceFolderURL
    }

    init(_ folderURL: URL, writeAction: @escaping ()-> Void) throws {
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)

        self.sourceFolderURL = folderURL
        self.queue = DispatchQueue(label: "folderwatcher.queue")
        
        let fileSystemRepresentation = (folderURL as NSURL).fileSystemRepresentation
        let fileDescriptor = open(fileSystemRepresentation, O_EVTONLY)

        let localSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: self.queue)
        localSource.setCancelHandler {
            close(fileDescriptor)
        }
        localSource.setEventHandler(handler: writeAction)

        self.source = localSource
        self.source.resume()
    }
    
    deinit {
        source.cancel()
    }
}
