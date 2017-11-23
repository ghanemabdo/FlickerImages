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
    var searchDelegate: ImageIndexDelegate? = nil
    var searchKey: SearchKey = ""
    var lastPage = 0
    var totalPages = 0
    var totalPhotos = ""
    var perpage = 0
    var imagesDict = Dictionary<ImageKey, FlickrImage>()
    var imagesList = [ImageKey]()
    
    var TotalPhotos: Int {
        guard let ttl = Int(totalPhotos) else {
            return 0
        }
        
        return ttl
    }
    
    func searchForKey(searchKey: SearchKey, delegate:ImageIndexDelegate) {
        if searchKey == self.searchKey || searchKey.count == 0 {
            return
        }
        
        self.searchDelegate = delegate
        imagesDict.removeAll()
        imagesList.removeAll()
        lastPage = 0
        self.searchKey = searchKey
        downloadNextPage()
    }
    
    func downloadNextPage() {
        lastPage += 1
        downloadPage(page: lastPage)
    }
    
    func downloadPage(page: Int) {
        let jsonOp = JSONNetworkOperation(searchKey: self.searchKey, page: page, delegate: self)
        jsonOp.start()
    }
    
    func extractInfoFromDict(jsonDict: Dictionary<String, AnyObject>) {
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
                            imagesList.insert(imgKey, at: 0)
                        }
                    }
                }
            }
        }
    }
    
    func createFlickrImageFromDict(dict: Dictionary<String, Any>) -> FlickrImage? {
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
    
    func getImageAtIndex(index: Int, delegate: ImageDownloadDelegate) -> FlickrImage? {
        if index < self.TotalPhotos {
            if index < self.imagesList.count {
                let imageKey = self.imagesList[index]
                if let image = self.imagesDict[imageKey] {
                    return ImageStash.sharedInstance.getImageDownloadIfNotExistLocally(flickrImage: image, delegate: delegate)
                }
            } else {
                self.downloadNextPage()
            }
        }
        
        return nil
    }
    
    // MARK: -- JSONDownloadDelegate --
    
    func JSONDictionaryDownloaded(jsonDict: Dictionary<String, Any>) {
        extractInfoFromDict(jsonDict: jsonDict as Dictionary<String, AnyObject>)
        searchDelegate?.imageIndexDownloaded()
    }
}
