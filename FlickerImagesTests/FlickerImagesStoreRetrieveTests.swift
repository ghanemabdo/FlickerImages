//
//  FlickerImagesStoreRetrieveTests.swift
//  FlickerImagesTests
//
//  Created by Abdurrahman Ibrahem Ghanem on 11/25/17.
//  Copyright © 2017 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import XCTest
@testable import FlickerImages

class FlickerImagesStoreRetrieveTests: XCTestCase, ImageDownloadDelegate, JSONDownloadDelegate, ImageIndexDelegate {
    
    private var flickrImage: FlickrImage? = nil
    private var expectation: XCTestExpectation? = nil
    
    override func setUp() {
        super.setUp()
        
        flickrImage = FlickrImage(id: "23451156376", owner: "28017113@N08", server: "578", secret: "8983a8ebc7", farm: 1, title: "Merry Christmas!", isPublic: 1, isFriend: 0, isFamily: 0)
        //flickrImage = ImagesStash.sharedInstance.getImageDownloadIfNotExistLocally(flickrImage: flickrImage!, delegate: self)
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testReadImageExistsInMemory() {
        self.testDownloadImage()
        let imageIn = ImagesStash.sharedInstance.getImage(flickrImage: flickrImage!)
        XCTAssertNotNil(imageIn?.Image, "Image downloaded but not found in stash")
        XCTAssert(Int((self.flickrImage?.Image?.size.width)!) == 400 && Int((self.flickrImage?.Image?.size.height)!) == 500, "found another image")
    }
    
    func testReadImageCachedOnDisk() {
        self.testDownloadImage()
        ImagesStash.sharedInstance.removeAllAndSaveToDisk()
        let imageIn = ImagesStash.sharedInstance.getImage(flickrImage: flickrImage!)
        XCTAssertNotNil(imageIn?.Image, "Image downloaded but not found in stash")
        XCTAssert(Int((self.flickrImage?.Image?.size.width)!) == 400 && Int((self.flickrImage?.Image?.size.height)!) == 500, "found another image")
    }
    
    func testDownloadImage() {
        ImagesStash.sharedInstance.removeImage(flickrImage: flickrImage!, andFromDisk: true)
        expectation = XCTestExpectation(description: "Downloading image")
        if let img = ImagesStash.sharedInstance.getImageDownloadIfNotExistLocally(flickrImage: flickrImage!, delegate: self) {
            XCTAssertNil(img, "Image downloading should return nil to sync path")
        } else {
            self.wait(for: [expectation!], timeout: 31)
        }
    }
    
    func imageDownloaded(flickrImage: FlickrImage) {
        let img = ImagesStash.sharedInstance.getImage(flickrImage: flickrImage)
        XCTAssertNotNil(img?.Image, "Image not downloaded")
        XCTAssert(Int((self.flickrImage?.Image?.size.width)!) == 400 && Int((self.flickrImage?.Image?.size.height)!) == 500, "Got wrong image")
        
        expectation?.fulfill()
    }
    
    func JSONDictionaryDownloaded(jsonDict: Dictionary<String, Any>?) {
        
    }
    
    func testDownloadImagesIndexPages() {
        //Download images in the first page
        expectation = XCTestExpectation(description: "Download images index first page")
        ImagesIndex.sharedInstance.searchForKey(searchKey: "kittens", delegate: self)
        self.wait(for: [expectation!], timeout: 21)
        //After the first page images are downloaded, try grabbing more pages and validate the numbers
        expectation = XCTestExpectation(description: "Download images index first page")
        ImagesIndex.sharedInstance.downloadNextPage()
        self.wait(for: [expectation!], timeout: 21)
    }
    
    func imageIndexDownloaded() {
        if expectation?.description == "Download images index first page" {
            XCTAssert(ImagesIndex.sharedInstance.PerPage == 100 && ImagesIndex.sharedInstance.TotalPages > 2000, "Error retrieving the first page")
        } else if expectation?.description == "Download images index more pages" {
            XCTAssert(ImagesIndex.sharedInstance.count >= ImagesIndex.sharedInstance.PerPage, "Wrong number of pages for subsequent pages")
        }
        
        expectation?.fulfill()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
