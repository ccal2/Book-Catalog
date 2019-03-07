//
//  Book.swift
//  Book Catalog
//
//  Created by Carolina Lopes on 28/02/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import UIKit
import CoreData

final class Book: NSManagedObject {
    
    // MARK: - Properties
    
    static let entityName: String = "Book"
    
    @NSManaged fileprivate(set) var recordName: String
    @NSManaged fileprivate(set) var colorName: String
    @NSManaged fileprivate(set) var title: String
    @NSManaged fileprivate(set) var authorName: String
    
    
    // MARK: - Methods
    
    static func insert(recordName: String, color: UIColor, name: String, authorName: String, into context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: Book.entityName, in: context)
        let newBook = NSManagedObject(entity: entity!, insertInto: context)
        
        newBook.setValue(recordName, forKey: Book.key(.recordName))
        newBook.setValue(color.name, forKey: Book.key(.colorName))
        newBook.setValue(name, forKey: Book.key(.title))
        newBook.setValue(authorName, forKey: Book.key(.authorName))
        
        print("inserted new book:", newBook)
    }
    
    static func update(recordName: String, color: UIColor, name: String, authorName: String, from context: NSManagedObjectContext) {
        // Check if the record already exists
        let request = NSFetchRequest<Book>(entityName: Book.entityName)
        request.predicate = NSPredicate(format: "recordName = %@", recordName)
        
        guard let result = try? context.fetch(request) else {
            print("Error fetching record with recordName:", recordName)
            return
        }
        
        if result.count == 0 {
            print("No record found with recordName:", recordName)
        } else if result.count > 1 {
            fatalError("Returned more than 1 record for recordName: \(recordName)")
        } else {
            // Update local record
            let record = result[0]
            
            record.colorName = color.name
            record.title = name
            record.authorName = authorName
            
            print("Updated local record with recordName:", recordName)
        }
    }
    
    static func delete(recordName: String, from context: NSManagedObjectContext) {
        // Fetch record
        let request = NSFetchRequest<Book>(entityName: Book.entityName)
        request.predicate = NSPredicate(format: "recordName = %@", recordName)
        
        guard let result = try? context.fetch(request) else {
            print("Error fetching record with recordName:", recordName)
            return
        }
        
        if result.count == 0 {
            print("No record found with recordName:", recordName)
        } else if result.count > 1 {
            fatalError("Returned more than 1 record for recordName: \(recordName)")
        } else {
            context.delete(result[0])
            
            print("Deleted record with recordName:", recordName)
        }
    }
    
}


// Keys for the entity attributes
extension Book {
    enum Keys: String {
        case recordName
        case colorName
        case title
        case authorName
    }
    
    // Get rawValue
    static func key(_ key: Book.Keys) -> String {
        return key.rawValue
    }
}
