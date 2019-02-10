//
//  WritingEndpoint.swift
//  CDShare
//
//  Created by IonVoda on 12/12/2018.
//  Copyright © 2018 IonVoda. All rights reserved.
//

import Foundation
import CoreData

public struct WritingEndpoint {
    let applicationNames: [ApplicationIdentifier]
    let contextSource: NSManagedObjectContext
}
