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
    
    func getBook(id: String) {
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
    
    
}

private extension DataManager {
    func saveBook(_ bookInfo: JSONDictionary) {
        guard let context = appDelegate?.persistentContainer.viewContext else { return }
        let fileManager = FileManager.default
        let book = SavedBook(context: context)
        book.authors = bookInfo["authors"] as? String
        book.isbn = bookInfo["ISBN_13"] as? String
        book.title = bookInfo["title"] as? String
        book.publisher = bookInfo["publisher"] as? String
        
        if let imageInfos = bookInfo["images"] as? [JSONDictionary] {
            for imageInfo in imageInfos {
                let image = SavedImage(context: context)
                image.page_number = imageInfo["page_number"] as! Int16
                image.title = imageInfo["title"] as? String
                if let imageFileString = (imageInfo["image_file"] as! JSONDictionary)["base64"] as? String {
                    image.imageFile = Data.init(base64Encoded: imageFileString)
                }
                if let modelFileString = (imageInfo["model_file"] as? String) {
                    image.modelFile = "\(image.title!).usdz"
                    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(image.modelFile!)
                    let modelData = Data.init(base64Encoded: modelFileString)!
                    fileManager.createFile(atPath: paths, contents: modelData, attributes: nil)
                }
                book.addToSavedImages(image)
            }
        }
        saveContext(context)
    }
    
    func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
}
