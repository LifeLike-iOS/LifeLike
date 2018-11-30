//
//  DataManager.swift
//  LifeLike
//
//  Created by Devin Fan on 11/12/18.
//  Copyright © 2018 Devin Fan. All rights reserved.
//

import Foundation
import CoreData
import UIKit

fileprivate typealias JSONDictionary = [String: Any]

class DataManager {
   
    static let shared = DataManager()
    
    let defaultSession = URLSession(configuration: .default)
    
    init() {
    }
    
    func searchForBooks(_ text: String, completion: @escaping (([Book]) -> ())) {
        if let url = URL(string: "https://lifelike-api.herokuapp.com/books/search/\(text)") {
            let dataTask = defaultSession.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print(error)
                }
                else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    do {
                        if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [JSONDictionary] {
                            completion(dict.map({ (bookInfo) -> Book in
                                return self.loadBookInfo(dict: bookInfo)
                            }))
                        }
                    } catch {
                        print(error)
                    }
                    
                }
            }
            dataTask.resume()
        }
    }
    
    func downloadBook(id: String) {
        // Gets one book with endpoint /books/[:id]
        
        if let url = URL(string: "https://lifelike-api.herokuapp.com/books/\(id)") {
            let dataTask = defaultSession.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print(error)
                }
                else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    do {
                        if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary {
                            self.saveBook(dict)
                        }
                    } catch {
                        print(error)
                    }
                    
                }
            }
            dataTask.resume()
        }
    }
    
    func getBook(id: String) -> Book? {
        weak var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        guard let context = appDelegate?.persistentContainer.viewContext else { return nil }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedBook")
        request.predicate = NSPredicate(format: "%K == %@", "oid", id)
        do {
            let result = try context.fetch(request) as! [NSManagedObject]
            if result.count > 0 {
                return loadBook(data: result.first!)
            }
        } catch {
            print(error)
        }
        return nil
    }
}

private extension DataManager {
    func saveBook(_ bookInfo: JSONDictionary) {
        weak var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        guard let context = appDelegate?.persistentContainer.viewContext else { return }
        let fileManager = FileManager.default
        let book = SavedBook(context: context)
        book.oid = (bookInfo["_id"] as! [String : String])["$oid"]
        book.authors = bookInfo["authors"] as? String
        book.isbn = bookInfo["ISBN_13"] as? String
        book.title = bookInfo["title"] as? String
        book.publisher = bookInfo["publisher"] as? String
        book.pageCount = bookInfo["page_count"] as! Int16
        
        if let imageInfos = bookInfo["images"] as? [JSONDictionary] {
            for imageInfo in imageInfos {
                let image = SavedImage(context: context)
                image.pageNumber = imageInfo["page_number"] as! Int16
                image.title = imageInfo["title"] as? String
                if let imageFileString = imageInfo["image_file"] as? String {
                    image.imageFile = Data.init(base64Encoded: imageFileString)
                }
                if let modelFileString = (imageInfo["model_file"] as? String) {
                    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(image.title!).usdz")
                    image.modelFile = paths
                    let modelData = Data.init(base64Encoded: modelFileString)!
                    fileManager.createFile(atPath: paths, contents: modelData, attributes: nil)
                }
                book.addToSavedImages(image)
            }
        }
        saveContext(context)
    }
    
    func loadBookInfo(dict: JSONDictionary) -> Book {
        let id = (dict["_id"] as! JSONDictionary)["$oid"] as! String
        let title = dict["title"] as! String
        let authors = dict["authors"] as! String
        let isbn = dict["ISBN_13"] as! String
        let publisher = dict["publisher"] as! String
        let pageCount = dict["page_count"] as! Int
        return Book(id: id, title: title, authors: authors, ISBN: isbn, publisher: publisher, pageCount: pageCount, images: [])
    }
    
    func loadBook(data: NSManagedObject) -> Book {
        let id = data.value(forKey: "oid") as! String
        let title = data.value(forKey: "title") as! String
        let authors = (data.value(forKey: "authors") as! String)
        let isbn = data.value(forKey: "isbn") as! String
        let publisher = data.value(forKey: "publisher") as! String
        let pageCount = data.value(forKey: "pageCount") as! Int
        let images = (data.value(forKey: "savedImages") as! Set).map { (savedImage) -> Image in
            loadImage(data: savedImage)
        }
        return Book(id: id, title: title, authors: authors, ISBN: isbn, publisher: publisher, pageCount: pageCount, images: images)
    }
    
    func loadImage(data: NSManagedObject) -> Image {
        let title = data.value(forKey: "title") as! String
        let imageFile = UIImage(data:(data.value(forKey: "imageFile") as! NSData) as Data, scale:1.0)
        let modelFile = data.value(forKey: "modelFile") as! String
        let pageNumber = data.value(forKey: "pageNumber") as! Int
        return Image(title: title, imageFile: imageFile!, modelFile: modelFile, pageNumber: pageNumber)
    }
    
    func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
}
