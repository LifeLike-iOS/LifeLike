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
   
    let defaultSession = URLSession(configuration: .default)
    weak var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    
    init() {
    }
    
    func downloadBook(id: String, _ completion: @escaping () -> ()) {
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
                            self.saveBook(dict, completion)
                        }
                    } catch {
                        print(error)
                    }
                    
                }
            }
            dataTask.resume()
        }
    }
    
    func getBook(title: String) -> Book? {
        guard let context = appDelegate?.persistentContainer.viewContext else { return nil }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedBook")
        request.predicate = NSPredicate(format: "%K == %@", "title", title)
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
    func saveBook(_ bookInfo: JSONDictionary, _ completion: () -> ()) {
        guard let context = appDelegate?.persistentContainer.viewContext else { return }
        let fileManager = FileManager.default
        let book = SavedBook(context: context)
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
        saveContext(context, completion)
    }
    
    func loadBook(data: NSManagedObject) -> Book {
        let title = data.value(forKey: "title") as! String
        let authors = (data.value(forKey: "authors") as? String) ?? ""
        let isbn = data.value(forKey: "isbn") as! String
        let publisher = data.value(forKey: "publisher") as! String
        let pageCount = data.value(forKey: "pageCount") as! Int
        let images = (data.value(forKey: "savedImages") as! Set).map { (savedImage) -> Image in
            loadImage(data: savedImage)
        }
        return Book(title: title, authors: authors, ISBN: isbn, publisher: publisher, pageCount: pageCount, images: images)
    }
    
    func loadImage(data: NSManagedObject) -> Image {
        let title = data.value(forKey: "title") as! String
        let imageFile = UIImage(data:(data.value(forKey: "imageFile") as! NSData) as Data, scale:1.0)
        let modelFile = data.value(forKey: "modelFile") as! String
        let pageNumber = data.value(forKey: "pageNumber") as! Int
        return Image(title: title, imageFile: imageFile!, modelFile: modelFile, pageNumber: pageNumber)
    }
    
    func saveContext(_ context: NSManagedObjectContext, _ completion: () -> ()) {
        do {
            try context.save()
            completion()
        } catch {
            print(error)
        }
    }
}
