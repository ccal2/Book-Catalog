//
//  Change.swift
//  Book Catalog Creator
//
//  Created by Carolina Lopes on 08/03/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import Foundation

class Change {
    
    // MARK: - Properties
    
    var type: String
    var timestamp: NSDate
    var changedRecordName: String
    
    
    // MARK:- Methods
    
    init(type: Change.Types, timestamp: NSDate, changedRecordname: String) {
        self.type = type.rawValue
        self.timestamp = timestamp
        self.changedRecordName = changedRecordname
    }
}

// Change types
extension Change {
    enum Types: String {
        case created
        case updated
        case deleted
    }
}
