//
//  ImageNetworkOperation.swift
//  FlickerImages
//
//  Created by Abdurrahman Ibrahem Ghanem on 11/21/17.
//  Copyright © 2017 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation
import UIKit

class ImageNetworkOperation: NetworkOperationDelegate {
    
    let defaultNetworkConnectionTimeout = 30
    var networkOperation: NetworkOperation? = nil
    var flickrImage: FlickrImage? = nil
    var imageDownloadDelegate: ImageDownloadDelegate? = nil
    
    init(flickrImage: FlickrImage, delegate: ImageDownloadDelegate) {
        self.flickrImage = flickrImage
        let url = self.buildURL(flickrImage: flickrImage) 
        self.networkOperation = NetworkOperation(url: url, delegate: self, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeout: defaultNetworkConnectionTimeout)
        self.imageDownloadDelegate = delegate
    }
    
    func buildURL(flickrImage: FlickrImage) -> String {
        
        let farm = flickrImage.farm
        let server = flickrImage.server
        let id = flickrImage.id
        let secret = flickrImage.secret 
        
        return String("http://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret).jpg")
    }
    
    func start() {
        self.networkOperation?.start()
    }
    
    func dataReady(data: Data) {
        if data.count > 0 {
            if let image = UIImage(data: data) {
                self.flickrImage?.image = image
                imageDownloadDelegate?.imageDownloaded(flickrImage: self.flickrImage!)
            }
        }
    }
    
}
