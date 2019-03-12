//
//  BookCollectionViewCell.swift
//  Book Catalog Creator
//
//  Created by Carolina Lopes on 08/03/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import UIKit

class BookCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    
    
    // MARK: - Methods
    
    func configure(for book: Book) {
        self.backgroundColor = UIColor.fromName(book.colorName)
        self.titleLabel.text = book.title
        self.authorNameLabel.text = book.authorName
    }
    
}
