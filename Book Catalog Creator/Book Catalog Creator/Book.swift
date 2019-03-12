//
//  Book.swift
//  Book Catalog Creator
//
//  Created by Carolina Lopes on 08/03/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import Foundation

class Book {
    
    // MARK: - Properties
    
    var recordName: String
    var colorName: String
    var title: String
    var authorName: String
    
    
    // MARK: - Methods
    
    init(recordName: String, colorName: String, title: String, authorName: String) {
        self.recordName = recordName
        self.colorName = colorName
        self.title = title
        self.authorName = authorName
    }
    
    static func hasRecodName(_ recordName: String, inArray array: [Book]) -> Bool {
        for book in array {
            if book.recordName == recordName {
                return true
            }
        }
        
        return false
    }
}
