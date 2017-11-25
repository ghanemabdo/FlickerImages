//
//  FlickerImagesTests.swift
//  FlickerImagesTests
//
//  Created by Abdurrahman Ibrahem Ghanem on 11/19/17.
//  Copyright © 2017 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import XCTest
@testable import FlickerImages

class FlickerImagesNetworkTests: XCTestCase, NetworkOperationDelegate, JSONDownloadDelegate, ImageDownloadDelegate {
    
    var flickrImage: FlickrImage? = nil
    var expectation: XCTestExpectation? = nil
    
    override func setUp() {
        super.setUp()

        flickrImage = FlickrImage(id: "23451156376", owner: "28017113@N08", server: "578", secret: "8983a8ebc7", farm: 1, title: "Merry Christmas!", isPublic: 1, isFriend: 0, isFamily: 0)
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testNetworkOperation() {
        expectation = self.expectation(description: "NetworkOperation: Load Json from Flickr")
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&format=json&nojsoncallback=1&safe_search=1&text=kittens"
        let networkOp = NetworkOperation(url: url, delegate: self, cachePolicy: .useProtocolCachePolicy, timeout: 20)
        networkOp.start()
        self.wait(for: [expectation!], timeout: 21)
    }
    
    func dataReady(data: Data) {
        XCTAssertNotNil(data, "error downloading data")
        XCTAssert(data.count > 10000, "Download not complete")
        expectation?.fulfill()
    }
    
    func testImageNetworkOperation() {
        expectation = self.expectation(description: "ImageNetworkOperation: Download image from Flickr")
        let imgOp = ImageNetworkOperation(flickrImage: flickrImage!, delegate: self)
        imgOp.start()
        
        self.wait(for: [expectation!], timeout: 31)
    }
    
    func imageDownloaded(flickrImage: FlickrImage) {
        XCTAssertNotNil(flickrImage.Image, "error downloading image")
        XCTAssert(Int((self.flickrImage?.Image?.size.width)!) == 400 && Int((self.flickrImage?.Image?.size.height)!) == 500, "Downloading the wrong image")
        expectation?.fulfill()
    }
    
    func testJSONNetworkOperation() {
        expectation = self.expectation(description: "JSONNetworkOperation: Download JSON Dict from Flickr")
        let jsonOp = JSONNetworkOperation(searchKey: "kittens", page: 1, delegate: self)
        jsonOp.start()
        
        self.wait(for: [expectation!], timeout: 21)
    }
    
    func JSONDictionaryDownloaded(jsonDict: Dictionary<String, Any>?) {
        XCTAssertNotNil(jsonDict, "No data retrieved or misformatted data")
        XCTAssert(jsonDict != nil && jsonDict!.count > 0, "Retrieved empty dictionary")
        expectation?.fulfill()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
