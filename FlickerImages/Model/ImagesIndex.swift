//
//  ImagesLibrary.swift
//  FlickerImages
//
//  Created by Abdurrahman Ibrahem Ghanem on 11/22/17.
//  Copyright © 2017 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation

typealias SearchKey = String

class ImagesIndex: JSONDownloadDelegate {
    
    static let sharedInstance = ImagesIndex()
    private var searchDelegate: ImageIndexDelegate? = nil
    private var searchKey: SearchKey = ""
    private var lastPage = 0
    private var totalPages = 0
    private var totalPhotos = "1"
    private var perpage = 0
    private var imagesDict = Dictionary<ImageKey, FlickrImage>()
    private var imagesList = [ImageKey]()
    private var isPageDownloadInProgress = false
    
    var TotalPhotos: Int {
        guard let ttl = Int(totalPhotos) else {
            return 0
        }
        
        return ttl
    }
    
    var count: Int {
        return imagesList.count
    }
    
    var TotalPages: Int {
        return self.totalPages
    }
    
    var PerPage: Int {
        return self.perpage
    }
    
    var nextPageLoadThreshold: Int {
        let numPages = (count - 1) / self.perpage
        let threshold = Int(0.8 * Double(self.perpage)) + numPages * self.perpage 
        return threshold
    }
    
    func removeAll() {
        self.imagesList.removeAll()
        self.imagesDict.removeAll()
        perpage = 0
        totalPages = 0
        lastPage = 0
        totalPhotos = "1"
        searchDelegate = nil
    }
    
    func removeImage(flickrImage: FlickrImage) {
        if let key = flickrImage.imageKey {
            self.imagesDict.removeValue(forKey: key)
            self.imagesList = self.imagesList.filter() { $0 != key }
            ImagesStash.sharedInstance.removeImage(flickrImage: flickrImage)
        }
    }
    
    func searchForKey(searchKey: SearchKey, delegate:ImageIndexDelegate) {
        if searchKey == self.searchKey || searchKey.count == 0 {
            return
        }
        
        self.isPageDownloadInProgress = false
        self.searchDelegate = delegate
        imagesDict.removeAll()
        imagesList.removeAll()
        ImagesStash.sharedInstance.removeAllAndSaveToDisk()
        lastPage = 0
        self.searchKey = searchKey
        downloadNextPage()
    }
    
    func downloadNextPage() {
        if self.imagesList.count < self.TotalPhotos && self.isPageDownloadInProgress == false {
            lastPage += 1
            self.isPageDownloadInProgress = true
            downloadPage(page: lastPage)
        }
    }
    
    func downloadPage(page: Int) {
        let jsonOp = JSONNetworkOperation(searchKey: self.searchKey, page: page, delegate: self)
        jsonOp.start()
    }
    
    func getImageAtIndex(index: Int, delegate: ImageDownloadDelegate) -> FlickrImage? {
        if index < self.TotalPhotos {
            if index < self.imagesList.count {
                let imageKey = self.imagesList[index]
                if let image = self.imagesDict[imageKey] {
                    return ImagesStash.sharedInstance.getImageDownloadIfNotExistLocally(flickrImage: image, delegate: delegate)
                }
            } else {
                self.downloadNextPage()
            }
        }
        
        return nil
    }
    
    func getImageKeyAtIndex(index: Int) -> ImageKey? {
        return imagesList[index]
    }
    
    private func extractInfoFromDict(jsonDict: Dictionary<String, AnyObject>) {
        if let photos = jsonDict["photos"] as? Dictionary<String,AnyObject> {
            if let ttlpg = photos["pages"] as? Int {
                self.totalPages = ttlpg
            }
            if let perpage = photos["perpage"] as? Int {
                self.perpage = perpage
            }
            if let ttl = photos["total"] as? String {
                self.totalPhotos = ttl
            }
            if let photoArray = photos["photo"] as? Array<Dictionary<String,AnyObject>> {
                for objDict in photoArray {
                    if let img = createFlickrImageFromDict(dict: objDict) {
                        if let imgKey = img.imageKey {
                            imagesDict[imgKey] = img
                            imagesList.append(imgKey)
                        }
                    }
                }
            }
        }
    }
    
    private func createFlickrImageFromDict(dict: Dictionary<String, Any>) -> FlickrImage? {
        if let id = dict["id"] as? String,
            let owner = dict["owner"] as? String,
            let secret = dict["secret"] as? String,
            let server = dict["server"] as? String,
            let farm = dict["farm"] as? Int,
            let title = dict["title"] as? String,
            let isFriend = dict["isfriend"] as? Int,
            let isPublic = dict["ispublic"] as? Int,
            let isFamily = dict["isfamily"] as? Int
        {
            let flickrImage = FlickrImage(id: id, owner: owner, server: server, secret: secret, farm: farm, title: title, isPublic: isPublic, isFriend: isFriend, isFamily: isFamily)
            return flickrImage
        }
        
        return nil
    }
    
    // MARK: -- JSONDownloadDelegate --
    
    internal func JSONDictionaryDownloaded(jsonDict: Dictionary<String, Any>?) {
        self.isPageDownloadInProgress = false
        if let dict = jsonDict as Dictionary<String, AnyObject>? {
            extractInfoFromDict(jsonDict: dict)
        }
        searchDelegate?.imageIndexDownloaded()
    }
    
    deinit {
        self.removeAll()
    }
}
