//
//  TodayViewController.swift
//  TutorialAppGroup
//
//  Created by IonVoda on 28/11/2018.
//  Copyright © 2018 IonVoda. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData
import CDShare

struct ApplicationIdentifierModel: ApplicationIdentifier {
    var identifier: String
}

struct ApplicationGroupInfoModel: ApplicationGroupInfo {
    var group: ApplicationIdentifier = ApplicationIdentifierModel(identifier: "group.voda.the.cdshare")
    var reading: ApplicationIdentifier = ApplicationIdentifierModel(identifier: "com.CDShareExample.CDShareExampleToday")
    var writing: [ApplicationIdentifier] = [ApplicationIdentifierModel(identifier: "com.CDShareExample")]
}

class TodayViewController: UIViewController, NCWidgetProviding {
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var valueLabel: UILabel!
	@IBOutlet weak var incrementButton: UIButton!

	private var counter: Counter!
	private var coreDataShare: CoreDataShare!
    private var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.preferredContentSize.height = 50

        let configuration = try! CoreDataShareConfiguration(ApplicationGroupInfoModel(), readingContext: context, writingContext: context)
        coreDataShare = try! CoreDataShare(configuration: configuration, viewContext: context)
        coreDataShare.sharedInScopeEntityNames = [String(describing: Counter.self)]
		
        fetchData()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: .CoreDataShareDidSave, object: nil)
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData


        completionHandler(NCUpdateResult.newData)
    }
	
	// MARK: - Logic
	@objc private func fetchData() {
        self.context.perform { [unowned self] () -> Void in
            self.context.refreshAllObjects()
            
            if let counter = NSManagedObject.findAllForEntity("Counter", context: self.context)?.last as? Counter {
                self.counter = counter
            } else {
                self.counter = (NSEntityDescription.insertNewObject(forEntityName: "Counter", into: self.context) as! Counter)
                self.counter.title = "Counter"
                self.counter.value = 0
            }
            self.save()
            DispatchQueue.main.async {
                self.updateUI()
            }
        }
	}
	
	@objc private func updateUI() {
		titleLabel.text = counter?.title
        valueLabel.text = String(counter.value)
	}
	
    private func save() {
        self.saveContext()
	}
	
	// MARK: - Actions
	@IBAction func incrementButtonAction(_ sender: UIButton) {
		if let valueText = self.valueLabel.text, let value = Int32(valueText) {
			counter.value = value + 1
		}
		
		updateUI()
		save()
	}

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainerShared(name: "CDShareExample")

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}

// MARK: - Core Data extension
extension TodayViewController {
    class NSPersistentContainerShared: NSPersistentContainer {
        override class func defaultDirectoryURL() -> URL {
            let identifier = ApplicationGroupInfoModel().group.identifier
            return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)!
        }
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
