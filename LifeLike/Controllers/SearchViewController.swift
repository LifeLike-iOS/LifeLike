//
//  SearchViewController.swift
//  LifeLike
//
//  Created by Tiffany Chen on 11/1/18.
//  Copyright © 2018 Devin Fan. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var dataManager = DataManager.shared
    var books = [Book]()
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "BookTableViewCell", bundle: .main), forCellReuseIdentifier: "bookTableCell")
        searchTextField.delegate = self as UITextFieldDelegate
        tableView.tableFooterView = UIView(frame: .zero)
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func pressedExitButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBookDetailView" {
            guard let indexPath = sender as? IndexPath else { return }
            let detailView = segue.destination as! BookDetailViewController
            detailView.book = books[indexPath.row]
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let query:String = searchTextField.text!
        dataManager.searchForBooks(query) { (books) in
            self.books = books
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        searchTextField.resignFirstResponder()
        return true
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookTableCell", for: indexPath) as! BookTableViewCell
        cell.titleLabel.text = books[indexPath.row].title
        cell.publisherLabel.text = books[indexPath.row].publisher
        cell.authorLabel.text = books[indexPath.row].authors
        cell.yearLabel.text = "1997"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showBookDetailView", sender: indexPath)
    }
}
