//
//  HomeViewController.swift
//  Book Catalog
//
//  Created by Carolina Lopes on 27/02/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, CollectionViewDataSourceDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var bookCollectionView: UICollectionView!
    fileprivate var dataSource: CollectionViewDataSource<HomeViewController>!
    
    
    // MARK: - Methods

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCollectionView()
    }
    
    // MARK: CollectionView Setup
    
    func setupCollectionView() {
        let request = NSFetchRequest<Book>(entityName: Book.entityName)
        let sortDescriptor = NSSortDescriptor(key: Book.key(.title), ascending: true)
        
        request.sortDescriptors = [sortDescriptor]
        request.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataManager.context, sectionNameKeyPath: nil, cacheName: nil)
        
        self.dataSource = CollectionViewDataSource(collectionView: self.bookCollectionView, cellIdentifier: "BookCell", fetchedResultsController: fetchedResultsController, delegate: self)
    }
    
    // MARK: CollectionViewDataSourceDelegate
    
    func configure(_ cell: BookCollectionViewCell, for object: Book) {
        cell.configure(for: object)
    }
    
}
