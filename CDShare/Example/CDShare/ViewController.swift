//
//  ViewController.swift
//  CDShare
//
//  Created by IonVoda on 12/12/2018.
//  Copyright © 2018 IonVoda. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var incrementButton: UIButton!
    
    private var counter: Counter!
    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchData), name: .CoreDataShareDidSave, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        titleLabel.text = counter.title
        valueLabel.text = String(counter.value)
    }
    
    private func save() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    // MARK: - Actions
    @IBAction func incrementButtonAction(_ sender: UIButton) {
        if let text = self.valueLabel.text, let value = Int32(text) {
            counter.value = value + 1
        }
        
        updateUI()
        save()
    }
}
