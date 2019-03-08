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
}


// Keys for the book record fields
extension CloudKitManager {
    enum Keys: String {
        case colorName
        case title
        case authorName
    }
    
    // Get rawValue
    static func key(_ key: CloudKitManager.Keys) -> String {
        return key.rawValue
    }
}
