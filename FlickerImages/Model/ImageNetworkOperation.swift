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
    
    private let defaultNetworkConnectionTimeout = 30
    private var networkOperation: NetworkOperation? = nil
    private var flickrImage: FlickrImage? = nil
    private var imageDownloadDelegate: ImageDownloadDelegate? = nil
    
    init(flickrImage: FlickrImage, delegate: ImageDownloadDelegate) {
        self.flickrImage = flickrImage
        let url = self.buildURL(flickrImage: flickrImage) 
        self.networkOperation = NetworkOperation(url: url, delegate: self, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeout: defaultNetworkConnectionTimeout)
        self.imageDownloadDelegate = delegate
    }
    
    func start() {
        self.networkOperation?.start()
    }
    
    private func buildURL(flickrImage: FlickrImage) -> String {
        
        let farm = flickrImage.Farm
        let server = flickrImage.Server
        let id = flickrImage.Id
        let secret = flickrImage.Secret 
        
        return String("http://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret).jpg")
    }
    
    internal func dataReady(data: Data) {
        if data.count > 0 {
            if let image = UIImage(data: data) {
                self.flickrImage?.Image = image
                imageDownloadDelegate?.imageDownloaded(flickrImage: self.flickrImage!)
            }
        }
    }
    
}
