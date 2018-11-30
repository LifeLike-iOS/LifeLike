//
//  BookDetailViewController.swift
//  LifeLike
//
//  Created by Tiffany Chen on 11/1/18.
//  Copyright © 2018 Devin Fan. All rights reserved.
//

import UIKit

class BookDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var publishingDateLabel: UILabel!
    @IBOutlet weak var numPagesLabel: UILabel!
    @IBOutlet weak var ISBNLabel: UILabel!
    var book: Book?
    var dataManager = DataManager.shared
    
    override func viewDidLoad() {
        guard let book = book else { return }
        titleLabel.text = book.title
        authorsLabel.text = book.authors
        publisherLabel.text = book.publisher
        publishingDateLabel.text = "1997"
        numPagesLabel.text = String(book.pageCount) + " pages"
        ISBNLabel.text = book.ISBN
    }
    
    @IBAction func pressedBackToSearch(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressedAddToCollection(_ sender: Any) {
        guard let book = book else { return }
        dataManager.downloadBook(id: book.id)
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}
