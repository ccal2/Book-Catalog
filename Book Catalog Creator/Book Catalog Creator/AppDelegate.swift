//
//  AppDelegate.swift
//  Book Catalog Creator
//
//  Created by Carolina Lopes on 08/03/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    
    var window: UIWindow?


    // MARK: - Methods
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        CloudKitManager.fetchAllRecords { (books, error) in
            if let error = error {
                print("Error fetching CloudKit records:", error)
            } else {
                var books = books ?? []
                
                books.sort(by: { $0.title < $1.title })
                
                DispatchQueue.main.async {
                    self.showCatalog(with: books)
                }
            }
        }
        
        return true
    }
    
    // Go to CatalogViewController
    func showCatalog(with books: [Book]) {
        let storyboard = self.window?.rootViewController?.storyboard
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "CatalogViewController") as? CatalogViewController else {
            fatalError("Cannot instantiate catalog view controller")
        }
        
        viewController.books = books
        self.window?.rootViewController = viewController
    }

}

