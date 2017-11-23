//
//  FlickrImage.swift
//  FlickerImages
//
//  Created by Abdurrahman Ibrahem Ghanem on 11/21/17.
//  Copyright © 2017 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation
import UIKit

typealias ImageKey = String

class FlickrImage: ImageDownloadDelegate {
    
    var image: UIImage?
    let id: String
    let owner: String
    let server: String
    let secret: String
    let farm: Int
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    var isInitialized: Bool = false
    var delegate: ImageDownloadDelegate? = nil
    
    init(id: String,
         owner: String,
         server: String,
         secret: String,
         farm: Int,
         title: String,
         isPublic: Int,
         isFriend: Int,
         isFamily: Int,
         delegate: ImageDownloadDelegate? = nil) {
        
        self.id = id
        self.owner = owner
        self.server = server
        self.secret = secret
        self.farm = farm
        self.title = title
        self.isPublic = isPublic
        self.isFamily = isFamily
        self.isFriend = isFriend
        self.isInitialized = true
        self.delegate = delegate
    }
    
    var imageKey: ImageKey? {
        if isInitialized {
            return "\(id)_\(secret)_\(server)_\(farm)"
        } else {
            return nil
        }
    }
    
    var Image: UIImage? {
        set(newImage) {
            self.image = newImage
        }
        get {
            return self.image
        }
    }
    
    func download(delegate: ImageDownloadDelegate) {
        if image == nil {
            self.delegate = delegate
            self.image = ImageStash.sharedInstance.getImageDownloadIfNotExistLocally(flickrImage: self, delegate: self)?.image
        }
    }
    
    func imageDownloaded(flickrImage: FlickrImage) {
        delegate?.imageDownloaded(flickrImage: flickrImage)
    }
}
