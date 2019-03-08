//
//  CloudKitManager.swift
//  Book Catalog
//
//  Created by Carolina Lopes on 06/03/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import CloudKit
import UIKit

final class CloudKitManager {
    
    // MARK: - Properties
    
    static var publicDatabase: CKDatabase {
        return CKContainer.default().publicCloudDatabase
    }
    
    static let recordType = "Book"
    static let changesRecordType = "Change"
    
    
    // MARK: - Methods
    
    fileprivate init() {
        // It's impossible to create instances of this class
    }
    
    static func fetchChanges() {
        var date: NSDate
        
        if let lastChangesFetch = UserDefaults.standard.object(forKey: UserDefaults.key(.lastChangesFetch)) as? NSDate {
            date = lastChangesFetch
        } else {
            date = NSDate(timeIntervalSince1970: 0.0)
        }
        
        let predicate = NSPredicate(format: "timestamp >= %@", date)
        let query = CKQuery(recordType: CloudKitManager.changesRecordType, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        
        var createdRecordNames: [String] = []
        var updatedRecordNames: [String] = []
        var deletedRecordNames: [String] = []
        
        operation.recordFetchedBlock = { (record) in
            if let type = record["type"] as? String, let changedRecordName = record["changedRecordName"] as? String {
                switch type{
                case "created":
                    createdRecordNames.append(changedRecordName)
                case "updated":
                    updatedRecordNames.append(changedRecordName)
                case "deleted":
                    deletedRecordNames.append(changedRecordName)
                default:
                    print("invalid change type")
                }
            }
        }
        
        CloudKitManager.executeQueryOperation(operation) {
            CloudKitManager.updateLocalStorage(created: createdRecordNames, updated: updatedRecordNames, deleted: deletedRecordNames) {
                UserDefaults.standard.set(NSDate(), forKey: UserDefaults.key(.lastChangesFetch))
                
                _ = CoreDataManager.context.saveOrRollback()
            }
        }
        
    }
    
    static func updateLocalStorage(created: [String], updated: [String], deleted: [String], completion: @escaping () -> Void) {
        // create books
        var createdIDs: [CKRecord.ID] = []
        
        for recordName in created {
            let recordID = CKRecord.ID(recordName: recordName)
            createdIDs.append(recordID)
        }
        
        let createdOperation = CKFetchRecordsOperation(recordIDs: createdIDs)
        
        createdOperation.perRecordCompletionBlock = { (record, recordID, error) in
            if let error = error {
                print("Error fetching record:", error)
            } else if let record = record {
                Book.insert(recordName: record.recordID.recordName, color: UIColor.fromName(record[CloudKitManager.key(.colorName)] ?? "brown"), title: record[CloudKitManager.key(.title)]!, authorName: record[CloudKitManager.key(.authorName)]!, into: CoreDataManager.context)
            }
        }
        
        // update books
        var updatedIDs: [CKRecord.ID] = []
        
        for recordName in updated {
            let recordID = CKRecord.ID(recordName: recordName)
            updatedIDs.append(recordID)
        }
        
        let updatedOperation = CKFetchRecordsOperation(recordIDs: updatedIDs)
        updatedOperation.addDependency(createdOperation)
        
        updatedOperation.perRecordCompletionBlock = { (record, recordID, error) in
            if let error = error {
                print("Error fetching record:", error)
            } else if let record = record {
                Book.update(recordName: record.recordID.recordName, color: UIColor.fromName(record[CloudKitManager.key(.colorName)] ?? "brown"), title: record[CloudKitManager.key(.title)]!, authorName: record[CloudKitManager.key(.authorName)]!, from: CoreDataManager.context)
            }
        }
        
        updatedOperation.fetchRecordsCompletionBlock = { (_, error) in
            if let error = error {
                print("Error fetching records:", error)
            } else {
                completion()
            }
        }
        
        CloudKitManager.publicDatabase.add(createdOperation)
        CloudKitManager.publicDatabase.add(updatedOperation)
        
        // delete books
        for recordName in deleted {
            Book.delete(recordName: recordName, from: CoreDataManager.context)
        }
    }
    
    static func fetchAllRecords() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: UserDefaults.key(.hasLaunchedBefore))
        
        if !hasLaunchedBefore {
            let predicate = NSPredicate(format: "TRUEPREDICATE")
            let query = CKQuery(recordType: CloudKitManager.recordType, predicate: predicate)
            let operation = CKQueryOperation(query: query)
            
            operation.recordFetchedBlock = { (record) in
                Book.insert(recordName: record.recordID.recordName, color: UIColor.fromName(record[CloudKitManager.key(.colorName)] ?? "brown"), title: record[CloudKitManager.key(.title)]!, authorName: record[CloudKitManager.key(.authorName)]!, into: CoreDataManager.context)
            }
            
            CloudKitManager.executeQueryOperation(operation) {
                UserDefaults.standard.set(true, forKey: UserDefaults.key(.hasLaunchedBefore))
            }
        }
    }
    
    static func executeQueryOperation(_ operation: CKQueryOperation, completion: @escaping () -> Void) {
        operation.queryCompletionBlock = { (cursor, error) in
            if let error = error {
                print("Error fetching cloudKit records:", error)
            } else if let cursor = cursor {
                let query = CKQueryOperation(cursor: cursor)
                
                CloudKitManager.executeQueryOperation(query, completion: completion)
            } else {
                _ = CoreDataManager.context.saveOrRollback()
                completion()
            }
        }
        
        CloudKitManager.publicDatabase.add(operation)
    }
}


// Keys for the record fields
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
