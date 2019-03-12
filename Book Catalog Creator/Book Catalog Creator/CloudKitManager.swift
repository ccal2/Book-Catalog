//
//  CloudKitManager.swift
//  Book Catalog Creator
//
//  Created by Carolina Lopes on 08/03/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import CloudKit

final class CloudKitManager {
    
    // MARK: - Properties
    
    static var publicDatabase: CKDatabase {
        let container = CKContainer(identifier: "iCloud.com.CarolinaLopes.Book-Catalog")
        return container.publicCloudDatabase
    }
    
    static let bookRecordType = "Book"
    static let changeRecordType = "Change"
    
    
    // MARK: - Methods
    
    fileprivate init() {
        // It's impossible to create instances of this class
    }
    
    // Fetch book records from cloud
    static func fetchAllRecords(completion: @escaping ([Book]?, Error?) -> Void) {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: CloudKitManager.bookRecordType, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        CloudKitManager.executeQueryOperation(operation) { (books, error) in
            completion(books, error)
        }
    }
    
    static func executeQueryOperation(_ operation: CKQueryOperation, completion: @escaping ([Book]?, Error?) -> Void) {
        var books: [Book] = []
        
        operation.recordFetchedBlock = { (record) in
            books.append(Book(recordName: record.recordID.recordName, colorName: record[CloudKitManager.key(.colorName)] ?? "brown", title: record[CloudKitManager.key(.title)] ?? "", authorName: record[CloudKitManager.key(.authorName)] ?? ""))
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            if let error = error {
                completion(nil, error)
            } else if let cursor = cursor {
                let queryOperation = CKQueryOperation(cursor: cursor)
                
                CloudKitManager.executeQueryOperation(queryOperation, completion: completion)
            } else {
                completion(books, nil)
            }
        }
        
        CloudKitManager.publicDatabase.add(operation)
    }
    
    // New book record
    static func insert(book: Book, completion: @escaping (Error?) -> Void) {
        let recordID = CKRecord.ID(recordName: book.recordName)
        
        let record = CKRecord(recordType: CloudKitManager.bookRecordType, recordID: recordID)
        record[CloudKitManager.key(.colorName)] = book.colorName
        record[CloudKitManager.key(.title)] = book.title
        record[CloudKitManager.key(.authorName)] = book.authorName
        
        CloudKitManager.publicDatabase.save(record) { (record, error) in
            if let error = error {
                completion(error)
            } else {
                print("record saved on cloud:", record!)
                
                // Add change record to cloud
                let newChange = Change(type: Change.Types.created, timestamp: NSDate(), changedRecordname: book.recordName)
                CloudKitManager.insert(change: newChange) { (error) in
                    completion(error)
                }
            }
        }
    }
    
    // Delete book record
    static func delete(_ book: Book, completion: @escaping (Error?) -> Void) {
        let recordID = CKRecord.ID(recordName: book.recordName)
        
        CloudKitManager.publicDatabase.delete(withRecordID: recordID) { (recordID, error) in
            if let error = error {
                completion(error)
            } else {
                print("record deleted from cloud with recordID:", recordID!)
                
                // Add change record to cloud
                let newChange = Change(type: Change.Types.deleted, timestamp: NSDate(), changedRecordname: book.recordName)
                CloudKitManager.insert(change: newChange) { (error) in
                    completion(error)
                }
            }
        }
    }
    
    // Update book record
    static func update(_ book: Book, completion: @escaping (Error?) -> Void) {
        let recordID = CKRecord.ID(recordName: book.recordName)
        
        // Fetch record from cloud
        CloudKitManager.publicDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let error = error {
                completion(error)
            } else {
                print("Fetched record from cloud:", record!)
                
                // Update record
                let updatedRecord = record!
                updatedRecord[CloudKitManager.key(.colorName)] = book.colorName
                updatedRecord[CloudKitManager.key(.title)] = book.title
                updatedRecord[CloudKitManager.key(.authorName)] = book.authorName
                
                CloudKitManager.publicDatabase.save(updatedRecord, completionHandler: { (record, error) in
                    if let error = error {
                        completion(error)
                    } else {
                        print("Saved updated record on cloud:", record!)
                        
                        // Add change record to cloud
                        let newChange = Change(type: Change.Types.updated, timestamp: NSDate(), changedRecordname: book.recordName)
                        CloudKitManager.insert(change: newChange) { (error) in
                            completion(error)
                        }
                    }
                })
            }
        }
    }
    
    // New change record
    static func insert(change: Change, completion: @escaping (Error?) -> Void) {
        let record = CKRecord(recordType: CloudKitManager.changeRecordType)
        record[CloudKitManager.key(.type)] = change.type
        record[CloudKitManager.key(.timestamp)] = change.timestamp
        record[CloudKitManager.key(.changedRecordName)] = change.changedRecordName
        
        CloudKitManager.publicDatabase.save(record) { (record, error) in
            if let error = error {
                completion(error)
            } else {
                print("Saved new change record to cloud:", record!)
                completion(nil)
            }
        }
    }
}


// Keys for the book record fields
extension CloudKitManager {
    enum Keys: String {
        // Book
        case colorName
        case title
        case authorName
        // Change
        case type
        case timestamp
        case changedRecordName
    }
    
    // Get rawValue
    static func key(_ key: CloudKitManager.Keys) -> String {
        return key.rawValue
    }
    
    
}
