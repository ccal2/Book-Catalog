//
//  CatalogViewController.swift
//  Book Catalog Creator
//
//  Created by Carolina Lopes on 08/03/19.
//  Copyright © 2019 Carolina Lopes. All rights reserved.
//

import UIKit
import CloudKit

class CatalogViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
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
        let alert = UIAlertController(title: "New book", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: self.titleTextFieldConfiguration)
        alert.addTextField(configurationHandler: self.authorNameTextFieldConfiguration)
        alert.addTextField(configurationHandler: self.colorNameTextFieldConfiguration)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (UIAlertAction) in
            let titleTtextField = alert.textFields![0]
            let authorNameTextField = alert.textFields![1]
            let colorNameTextField = alert.textFields![2]
            
            // Check if the fields for book title and author name are empty
            guard let title = titleTtextField.text, title != "", let authorName = authorNameTextField.text, authorName != "" else {
                let emptyAlert = UIAlertController(title: "Empty field", message: "You can't save a book without a title or an author", preferredStyle: .alert)
                emptyAlert.addAction(UIKit.UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                DispatchQueue.main.async {
                    self.present(emptyAlert, animated: true, completion: nil)
                }
                
                return
            }
            
            var colorName: String
            if let colorName_ = colorNameTextField.text, colorName_ != "" {
                colorName = colorName_
            } else {
                colorName = "brown"
            }
            
            var recordName = authorName + "--" + title
            recordName = recordName.replacingOccurrences(of: " ", with: "_")
            
            // Check if the book is already on the catalog
            if Book.hasRecodName(recordName, inArray: self.books) {
                let repeatAlert = UIAlertController(title: "This book already exists", message: "You can only add different books to the catalog", preferredStyle: .alert)
                repeatAlert.addAction(UIKit.UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                DispatchQueue.main.async {
                    self.present(repeatAlert, animated: true, completion: nil)
                }
            }
            
            // Add new book to cloud
            let newBook = Book(recordName: recordName, colorName: colorName, title: title, authorName: authorName)
            CloudKitManager.insert(book: newBook, completion: { (error) in
                // Check for errors
                if let error = error {
                    print("Error inserting new record on cloud:", error)
                    
                    if let ckError = error as? CKError {
                        if ckError.code == CKError.Code.networkUnavailable || ckError.code == CKError.Code.networkFailure {
                            let networkAlert = UIAlertController(title: "Network unavailable", message: "Please check your network connection and try again", preferredStyle: .alert)
                            networkAlert.addAction(UIKit.UIAlertAction(title: "Ok", style: .default, handler: nil))
                            
                            DispatchQueue.main.async {
                                self.present(networkAlert, animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    // Add new book to local catalog
                    self.books.append(newBook)
                    self.books.sort(by: { $0.title < $1.title })
                    
                    DispatchQueue.main.async {
                        self.colelctionView.reloadData()
                    }
                }
            })
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Alert textFields' configuration
    
    func titleTextFieldConfiguration(textField: UITextField!) {
        if textField != nil {
            textField.placeholder = "Book title"
        }
        
        textField.delegate = self
    }
    
    func authorNameTextFieldConfiguration(textField: UITextField!) {
        if textField != nil {
            textField.placeholder = "Author name"
        }
        
        textField.delegate = self
    }
    
    func colorNameTextFieldConfiguration(textField: UITextField!) {
        if textField != nil {
            textField.placeholder = "Book cover color name"
        }
        
        textField.delegate = self
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

