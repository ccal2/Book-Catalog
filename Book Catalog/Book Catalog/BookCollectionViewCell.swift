//
//  BookCollectionViewCell.swift
//  Book Catalog
//
//  Created by Carolina Lopes on 27/02/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import UIKit

class BookCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    
    
    // MARK: - Methods
    
    func updateContent(color: UIColor = .brown, title: String, authorName: String) {
        self.backgroundColor = color
        self.titleLabel.text = title
        self.authorNameLabel.text = authorName
    }
    
    func configure(for book: Book) {
        self.backgroundColor = UIColor.fromName(book.colorName)
        self.titleLabel.text = book.name
        self.authorNameLabel.text = book.authorName
    }
    
}
