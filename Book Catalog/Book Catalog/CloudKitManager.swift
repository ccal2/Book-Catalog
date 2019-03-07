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
    
    
    // MARK: - Methods
    
    fileprivate init() {
        // It's impossible to create instances of this class
    }
    
    static func subscribeToChanges() {
        let isSubscribed = UserDefaults.standard.bool(forKey: UserDefaults.key(.subscribedToPublicChanges))
        
        if !isSubscribed {
            let subscription = CKQuerySubscription(recordType: CloudKitManager.recordType, predicate: NSPredicate(format: "TRUEPREDICATE"), subscriptionID: "publicChanges", options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])
            let notificationInfo = CKSubscription.NotificationInfo()
            
            notificationInfo.shouldSendContentAvailable = true
            subscription.notificationInfo = notificationInfo

            CloudKitManager.publicDatabase.save(subscription) { (subscription, error) in
                if let error = error {
                    print("Error creating public subscription:", error)
                } else {
                    print("Created publicChanges subscription to Book recordType")
                    UserDefaults.standard.setValue(true, forKey: UserDefaults.key(.subscribedToPublicChanges))
                }
            }
        }
    }
    
    static func handleNotification(_ notification: CKQueryNotification, completion: @escaping () -> Void) {
        guard let recordID = notification.recordID else {
            print("Error: no recordID on notification")
            
            return
        }
        
        CloudKitManager.publicDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let error = error {
                print("Error fetching record:", error)
            } else if let record = record {
                switch notification.queryNotificationReason {
                case .recordCreated:
                    Book.insert(recordName: record.recordID.recordName, color: UIColor.fromName(record[CloudKitManager.key(.colorName)] ?? "brown"), title: record[CloudKitManager.key(.title)]!, authorName: record[CloudKitManager.key(.authorName)]!, into: CoreDataManager.context)
                case .recordUpdated:
                    Book.update(recordName: record.recordID.recordName, color: UIColor.fromName(record[CloudKitManager.key(.colorName)]!), name: record[CloudKitManager.key(.title)]!, authorName: record[CloudKitManager.key(.authorName)]!, from: CoreDataManager.context)
                case .recordDeleted:
                    Book.delete(recordName: record.recordID.recordName, from: CoreDataManager.context)
                }
                
                completion()
            }
        }
    }
    
    static func fetchAllRecords() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: UserDefaults.key(.hasLaunchedBefore))
        
        if !hasLaunchedBefore {
            let predicate = NSPredicate(format: "TRUEPREDICATE")
            let query = CKQuery(recordType: CloudKitManager.recordType, predicate: predicate)
            let operation = CKQueryOperation(query: query)
            
            CloudKitManager.executeQueryOperation(operation) {
                UserDefaults.standard.set(true, forKey: UserDefaults.key(.hasLaunchedBefore))
            }
        }
    }
    
    static func executeQueryOperation(_ operation: CKQueryOperation, completion: @escaping () -> Void) {
        operation.recordFetchedBlock = { (record) in
            Book.insert(recordName: record.recordID.recordName, color: UIColor.fromName(record[CloudKitManager.key(.colorName)] ?? "brown"), title: record[CloudKitManager.key(.title)]!, authorName: record[CloudKitManager.key(.authorName)]!, into: CoreDataManager.context)
        }
        
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
