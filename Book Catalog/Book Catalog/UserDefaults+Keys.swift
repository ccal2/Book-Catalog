//
//  UserDefaults+Keys.swift
//  Book Catalog
//
//  Created by Carolina Lopes on 07/03/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum Keys: String {
        case hasLaunchedBefore          // Bool
        case lastChangesFetch           // Date
    }
    
    static func key(_ key: UserDefaults.Keys) -> String {
        return key.rawValue
    }
}
