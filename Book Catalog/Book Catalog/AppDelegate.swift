//
//  AppDelegate.swift
//  Book Catalog
//
//  Created by Carolina Lopes on 27/02/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties

    var window: UIWindow?


    // MARK: - Methods
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        application.registerForRemoteNotifications()
        
        CoreDataManager.createContainer("Catalog") {
            guard let viewController = self.window?.rootViewController else {
                fatalError("Error trying to get rootViewController")
            }
            
            if viewController.restorationIdentifier != "LoadCDViewController" {
                fatalError("Error trying to get LoadCDViewController")
            }
            
            DispatchQueue.main.async {
                viewController.performSegue(withIdentifier: "showCatalog", sender: nil)
            }
        }
        
        CloudKitManager.subscribeToChanges()
        CloudKitManager.fetchAllRecords()
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received notification")
        
        let dict = userInfo as! [String: NSObject]
        let notification = CKQueryNotification(fromRemoteNotificationDictionary: dict)
        
        if notification.subscriptionID == "publicChanges" {
            print(notification)
            
            CloudKitManager.handleNotification(notification) {
                completionHandler(.newData)
            }
        }
    }

}

