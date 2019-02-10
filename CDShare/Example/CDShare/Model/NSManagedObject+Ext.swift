//
//  NSManagedObject+Ext.swift
//  CDShare_Example
//
//  Created by Voda Ion on 1/22/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    public class func findAllForEntity(_ entityName: String, context: NSManagedObjectContext) -> [AnyObject]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        let result: [AnyObject]?
        do {
            result = try context.fetch(request)
        } catch let error as NSError {
            print(error)
            result = nil
        }
        return result
    }
}

