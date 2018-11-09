//
//  LifeLikeTests.swift
//  LifeLikeTests
//
//  Created by Tiffany Chen on 11/8/18.
//  Copyright © 2018 Devin Fan. All rights reserved.
//

import XCTest
import UIKit
@testable import LifeLike

class LifeLikeTests: XCTestCase {

    private var bundle: Bundle {
      return Bundle(for: LifeLikeTests.self)
    }
  
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateImage() {
        let title: String = "Test"
        let imageData: Data = try! Data(contentsOf: self.bundle.url(forResource: "dog", withExtension: "jpeg") as URL!)
        let imageFile: UIImage = UIImage(data: imageData)!
        let testURL: String = "http://google.com"
        let testImage: Image = Image(title: title, imageFile: imageFile, modelFile: testURL)
      
        XCTAssertNotNil(testImage)
        XCTAssertEqual("Test", testImage.title)
        XCTAssertEqual("http://google.com", testImage.modelFile)
    }
  
    func testCreateBook() {
        let title: String = "Test"
        let imageData: Data = try! Data(contentsOf: self.bundle.url(forResource: "dog", withExtension: "jpeg") as URL!)
        let imageFile: UIImage = UIImage(data: imageData)!
        let testURL: String = "http://google.com"
        let testImage: Image = Image(title: title, imageFile: imageFile, modelFile: testURL)
      
        let title2: String = "Test"
        let imageData2: Data = try! Data(contentsOf: self.bundle.url(forResource: "succulent", withExtension: "jpeg") as URL!)
        let imageFile2: UIImage = UIImage(data: imageData)!
        let testURL2: String = "http://google.com"
        let testImage2: Image = Image(title: title2, imageFile: imageFile2, modelFile: testURL2)
      
        XCTAssertNotNil(testImage)
        XCTAssertNotNil(testImage2)
      
        let images: [Image] = [testImage, testImage2]
        let book = Book(title: "Test Book", authors: "Devin Fan, Tiffany Chen", ISBN: "123456789", publisher: "Blep" , publicationDate: Date(), pageCount: 20, chapterCount: 10, images: images)
      
        XCTAssertNotNil(book)
        XCTAssertEqual(book.title, "Test Book")
        XCTAssertEqual(book.authors, "Devin Fan, Tiffany Chen")
        XCTAssertEqual(book.ISBN, "123456789")
        XCTAssertEqual(book.images.count, 2)
    }
  
  
}
