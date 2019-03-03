//
//  CollectionViewDataSource.swift
//  Book Catalog
//
//  Created by Carolina Lopes on 28/02/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import UIKit
import CoreData

protocol CollectionViewDataSourceDelegate: class {
    func configure(_ cell: BookCollectionViewCell, for object: Book)
}

class CollectionViewDataSource<Delegate: CollectionViewDataSourceDelegate>: NSObject, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    fileprivate let collectionView: UICollectionView
    fileprivate let fetchedResultsController: NSFetchedResultsController<Book>
    fileprivate weak var delegate: Delegate!
    fileprivate let cellIdentifier: String
    
    
    // MARK: - Methods
    
    // MARK: Life Cycle
    
    required init(collectionView: UICollectionView, cellIdentifier: String, fetchedResultsController: NSFetchedResultsController<Book>, delegate: Delegate) {
        self.collectionView = collectionView
        self.cellIdentifier = cellIdentifier
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        
        super.init()
        
        self.fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        
        self.collectionView.dataSource = self
        self.collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = self.fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as? BookCollectionViewCell else {
            fatalError("Unexpected cell type at \(indexPath)")
        }
        
        let object = self.fetchedResultsController.object(at: indexPath)
        
        delegate.configure(cell, for: object)
        
        return cell
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    // Update the collectionView according to changes on the NSManagedObject (Book)
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.collectionView.reloadData()
    }
}
