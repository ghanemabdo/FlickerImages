//
//  FlickrImageCell.swift
//  FlickerImages
//
//  Created by Abdurrahman Ibrahem Ghanem on 11/23/17.
//  Copyright © 2017 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation
import UIKit

class FlickrImageCell: UICollectionViewCell, ImageDownloadDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    private var flickrImage: FlickrImage? = nil
    private var lastImageKey: ImageKey? = nil
    
    var LastImageKey: ImageKey? {
        set(newValue) {
            self.lastImageKey = newValue
        }
        get {
            return lastImageKey
        }
    }
    
    func resetCell() {
        self.imageView.image = nil
        self.activityIndicatorView.isHidden = false
        self.activityIndicatorView.startAnimating()
        self.bringSubview(toFront: self.activityIndicatorView)
        ImagesStash.sharedInstance.ignoreDelegateForImage(flickrImage: self.flickrImage)
        self.flickrImage = nil
        self.lastImageKey = nil
    }
    
    func setImage(flickrImage: FlickrImage) {
        if let image = flickrImage.Image { 
            self.imageView.image = image
            self.lastImageKey = flickrImage.imageKey
            self.bringSubview(toFront: self.imageView)
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
        }
    }
    
    // MARK: -- ImageDownloadDelegate methods --
    internal func imageDownloaded(flickrImage: FlickrImage) {
        DispatchQueue.main.async {
            if flickrImage.imageKey == self.lastImageKey {
                self.setImage(flickrImage: flickrImage)
            }
        }
    }
}
