//
//  CatalogViewController.swift
//  Book Catalog Creator
//
//  Created by Carolina Lopes on 08/03/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import UIKit

class CatalogViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Properties
    
    var books: [Book] = []
    
    // MARK: IBOutlets
    
    @IBOutlet weak var colelctionView: UICollectionView!
    
    
    // MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.colelctionView.delegate = self
        self.colelctionView.dataSource = self
    }
    
    // configure book cell with the book data
    func configure(_ cell: BookCollectionViewCell, for book: Book) {
        cell.configure(for: book)
    }
    
    // MARK: IBActions
    
    @IBAction func insertBook(_ sender: Any) {
        //
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCollectionViewCell", for: indexPath) as? BookCollectionViewCell else {
            fatalError("Unexpected cell type at \(indexPath)")
        }
        
        let book = self.books[indexPath.row]

        self.configure(cell, for: book)

        return cell
    }
    
}

