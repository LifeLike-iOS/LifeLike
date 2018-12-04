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
    var results = [Book]()
    var fetchResultsController: NSFetchedResultsController<SavedBook>?
    
    override func viewDidLoad() {
        navigationController?.isNavigationBarHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "BookTableViewCell", bundle: .main), forCellReuseIdentifier: "bookTableCell")
        searchTextField.delegate = self as UITextFieldDelegate
        tableView.tableFooterView = UIView(frame: .zero)
        let fetchRequest = NSFetchRequest<SavedBook>(entityName: "SavedBook")
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController?.delegate = self
        do {
            try fetchResultsController?.performFetch()
        } catch {
            print(error)
        }
    }
    
    @IBAction func pressedExitButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBookDetailView" {
            guard let indexPath = sender as? IndexPath else { return }
            let detailView = segue.destination as! BookDetailViewController
            detailView.book = results[indexPath.row]
            detailView.owned = ((fetchResultsController?.fetchedObjects?.first(where: { (savedBook) -> Bool in savedBook.oid! == results[indexPath.row].id })) != nil)
        }
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let query:String = searchTextField.text!
        dataManager.searchForBooks(query) { (results) in
            self.results = results
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
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookTableCell", for: indexPath) as! BookTableViewCell
        cell.titleLabel.text = results[indexPath.row].title
        cell.publisherLabel.text = results[indexPath.row].publisher
        cell.authorLabel.text = results[indexPath.row].authors
        cell.yearLabel.text = "1997"
        if ((fetchResultsController?.fetchedObjects?.first(where: { (savedBook) -> Bool in savedBook.oid! == results[indexPath.row].id })) == nil) {
            cell.checkmarkImage.image = nil
        } else {
            cell.checkmarkImage.image = UIImage(named: "checkmark")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showBookDetailView", sender: indexPath)
    }
}

extension SearchViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
