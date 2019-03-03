//
//  AppDelegate.swift
//  Book Catalog
//
//  Created by Carolina Lopes on 27/02/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties

    var window: UIWindow?


    // MARK: - Methods
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
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
        
        return true
    }

}

