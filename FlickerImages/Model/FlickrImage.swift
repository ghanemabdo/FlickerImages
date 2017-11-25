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
    
    private var image: UIImage?
    private let id: String
    private let owner: String
    private let server: String
    private let secret: String
    private let farm: Int
    private let title: String
    private let isPublic: Int
    private let isFriend: Int
    private let isFamily: Int
    private var isInitialized: Bool = false
    private var delegate: ImageDownloadDelegate? = nil
    
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
    
    var Farm: Int {
        return self.farm
    }
    
    var Id: String {
        return self.id
    }
    
    var Secret: String {
        return self.secret
    }
    
    var Owner: String {
        return self.owner
    }
    
    var Server: String {
        return self.server
    }
    
    var Title: String {
        return self.title
    }
    
    func download(delegate: ImageDownloadDelegate) {
        if image == nil {
            self.delegate = delegate
            self.image = ImagesStash.sharedInstance.getImageDownloadIfNotExistLocally(flickrImage: self, delegate: self)?.image
        }
    }
    
    internal func imageDownloaded(flickrImage: FlickrImage) {
        delegate?.imageDownloaded(flickrImage: flickrImage)
    }
    
    deinit {
        self.image = nil
    }
}
