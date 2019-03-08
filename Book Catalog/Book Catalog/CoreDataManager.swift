//
//  CoreDataManager.swift
//  Book Catalog
//
//  Created by Carolina Lopes on 28/02/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import CoreData

final class CoreDataManager {
    
    // MARK: - Properties
    
    static var context: NSManagedObjectContext!
    
    
    // MARK: - Methods
    
    fileprivate init() {
        // It is not possible to create an instance of this class
    }
    
    // !!!!---- Call this methods before using the property 'context' (preferably at app launch)  ----!!!!
    static func createContainer(_ name: String, completion: @escaping () -> ()) {
        let container = NSPersistentContainer(name: name)
        
        container.loadPersistentStores { (_, error) in
            guard error == nil else {
                print("Error loading persistent stores:", error!)
                return
            }
            
            self.context = container.viewContext
            
            completion()
        }
    }
}

extension NSManagedObjectContext {
    func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
}
