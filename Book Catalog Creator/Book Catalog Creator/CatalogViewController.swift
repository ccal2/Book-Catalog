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
    
    // Delete book from catalog
    func delete(_ book: Book, at index: Int) {
        CloudKitManager.delete(book) { (error) in
            if !self.checkForNetworkFailure(error) {
                self.books.remove(at: index)
                
                DispatchQueue.main.async {
                    self.colelctionView.reloadData()
                }
                
                print("deleted book record from cloud:", book)
            }
        }
    }
    
    // Check for connection error
    func checkForNetworkFailure(_ error: Error?) -> Bool {
        if let ckError = error as? CKError {
            if ckError.code == CKError.Code.networkUnavailable || ckError.code == CKError.Code.networkFailure {
                let networkAlert = UIAlertController(title: "Network unavailable", message: "Please check your network connection and try again", preferredStyle: .alert)
                networkAlert.addAction(UIKit.UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                DispatchQueue.main.async {
                    self.present(networkAlert, animated: true, completion: nil)
                }
                
                return true
            }
        }
        
        return false
    }
    
    // MARK: IBActions
    
    @IBAction func insertBook(_ sender: Any) {
        let alert = UIAlertController(title: "New book", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: self.titleTextFieldConfiguration)
        alert.addTextField(configurationHandler: self.authorNameTextFieldConfiguration)
        alert.addTextField(configurationHandler: self.colorNameTextFieldConfiguration)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (UIAlertAction) in
            let newBook = self.getBook(fromTextFields: alert.textFields!)
            
            // Check if the book is already on the catalog
            if Book.hasRecodName(newBook.recordName, inArray: self.books) {
                let repeatAlert = UIAlertController(title: "This book already exists", message: "You can only add different books to the catalog", preferredStyle: .alert)
                repeatAlert.addAction(UIKit.UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                DispatchQueue.main.async {
                    self.present(repeatAlert, animated: true, completion: nil)
                }
            }
            
            // Add new book to cloud
            CloudKitManager.insert(book: newBook, completion: { (error) in
                if !self.checkForNetworkFailure(error) {
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
    
    // MARK: Get book information
    
    func getBook(fromTextFields textFields: [UITextField], withRecordName oldRecordName: String? = nil) -> Book{
        let titleTextField = textFields[0]
        let authorNameTextField = textFields[1]
        let colorNameTextField = textFields[2]
        
        let (title, authorName) = self.getTitleAndAuthorName(titleTextField, authorNameTextField)
        let colorName = self.getColorName(colorNameTextField)
        
        // get recordName
        var recordName: String
        if let oldRecordName = oldRecordName {  // when updating an existing record
            recordName = oldRecordName
        } else {
            recordName = authorName + "--" + title
            recordName = recordName.replacingOccurrences(of: " ", with: "_")
        }
        
        return Book(recordName: recordName, colorName: colorName, title: title, authorName: authorName)
    }
    
    func getTitleAndAuthorName(_ titleTextField: UITextField, _ authorNameTextField: UITextField)  -> (String, String) {
        // Check if the fields for book title and author name are empty
        guard let title = titleTextField.text, title != "", let authorName = authorNameTextField.text, authorName != "" else {
            let emptyAlert = UIAlertController(title: "Empty field", message: "You can't save a book without a title or an author", preferredStyle: .alert)
            emptyAlert.addAction(UIKit.UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            DispatchQueue.main.async {
                self.present(emptyAlert, animated: true, completion: nil)
            }
            
            return ("", "")
        }
        
        return (title, authorName)
    }
    
    func getColorName(_ colorNameTextField: UITextField) -> String {
        if let colorName = colorNameTextField.text, colorName != "" {
            return colorName
        } else {
            return "brown"
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = self.books[indexPath.row]
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action) in
            //
        }))
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.delete(book, at: indexPath.row)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
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


// Alert textFields' configuration
extension CatalogViewController {
    
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
    
}
