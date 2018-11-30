//
//  BooksCollectionViewController.swift
//  LifeLike
//
//  Created by Tiffany Chen on 11/20/18.
//  Copyright © 2018 Devin Fan. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class BooksCollectionViewController: UIViewController {
  
    @IBOutlet weak var collectionView: UICollectionView!
    var dataManager = DataManager.shared
    var fetchResultsController: NSFetchedResultsController<SavedBook>?
    
    override func viewDidLoad() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        collectionView.delegate = self as UICollectionViewDelegate
        collectionView.dataSource = self as UICollectionViewDataSource
        collectionView.register(UINib(nibName: "BookViewCell", bundle: .main), forCellWithReuseIdentifier: "bookViewCell")
        collectionView.backgroundColor = UIColor.clear
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext 
        let fetchRequest = NSFetchRequest<SavedBook>(entityName: "SavedBook")
        // Configure the request's entity, and optionally its predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultsController?.delegate = self
        do {
            try fetchResultsController?.performFetch()
        } catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showARView" {
            guard let indexPath = sender as? IndexPath else { return }
            guard let arViewController = segue.destination as? ARViewController else { return }
            arViewController.book = dataManager.getBook(id: (fetchResultsController?.object(at: indexPath).oid)!)
        }
    }

}

extension BooksCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResultsController?.fetchedObjects?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookViewCell", for: indexPath) as! BookViewCell
        let book = fetchResultsController?.object(at: indexPath)
        cell.titleLabel.text = book?.title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showARView", sender: indexPath)
    }
}

extension BooksCollectionViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
}
