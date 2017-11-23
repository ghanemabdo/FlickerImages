//
//  FlickerImagesTests.swift
//  FlickerImagesTests
//
//  Created by Abdurrahman Ibrahem Ghanem on 11/19/17.
//  Copyright © 2017 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import XCTest
@testable import FlickerImages

class FlickerImagesTests: XCTestCase, JSONDownloadDelegate, ImageDownloadDelegate {
    
    var jsonOp: JSONNetworkOperation? = nil
    var jsonDict: Dictionary<String, Any>? = nil
    var flickrImage: FlickrImage? = nil
    var imgOp: ImageNetworkOperation? = nil
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        jsonOp = JSONNetworkOperation(searchKey: "kitten", page: 1, delegate: self)
        
        flickrImage = FlickrImage(id: "23451156376", owner: "28017113@N08", server: "578", secret: "8983a8ebc7", farm: 1, title: "Merry Christmas!", isPublic: 1, isFriend: 0, isFamily: 0)
        imgOp = ImageNetworkOperation(flickrImage: flickrImage!, delegate: self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        jsonOp?.start()
        while self.jsonDict == nil {
            
        }
        XCTAssert(self.jsonDict?.count == 2)
        
        imgOp?.start()
        while self.flickrImage?.image == nil {
            
        }
        XCTAssert(self.flickrImage?.image != nil && (self.flickrImage?.image?.size.width)! > CGFloat(0) && (self.flickrImage?.image?.size.height)! > CGFloat(0))
        
        ImagesIndex.sharedInstance.searchForKey(searchKey: "kitten")
        while ImagesIndex.sharedInstance.imagesDict.count <= 0 {
            
        }
        XCTAssert(ImagesIndex.sharedInstance.perpage == 100 && ImagesIndex.sharedInstance.totalPages > 2000)
        ImagesIndex.sharedInstance.downloadNextPage()
        XCTAssert(ImagesIndex.sharedInstance.perpage == 100 && ImagesIndex.sharedInstance.totalPages > 2000 && ImagesIndex.sharedInstance.imagesDict.count > 0)
    }
    
    func JSONDictionaryDownloaded(jsonDict: Dictionary<String, Any>) {
        //print(dump(jsonDict))
        self.jsonDict = jsonDict
        
    }
    
    func imageDownloaded(flickrImage: FlickrImage) {
        //print("\(image.size.width) x \(image.size.height)")
        self.flickrImage = flickrImage
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
