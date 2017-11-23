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
    
    var flickrImage: FlickrImage? = nil
    var index: Int? = nil
    
    func resetCell() {
        self.imageView.image = nil
        self.activityIndicatorView.isHidden = false
        self.activityIndicatorView.startAnimating()
        self.bringSubview(toFront: self.activityIndicatorView)
        self.flickrImage = nil
        self.index = nil
    }
    
    func setImage(flickrImage: FlickrImage) {
        if let image = flickrImage.image { 
            self.imageView.image = image
            self.bringSubview(toFront: self.imageView)
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
        }
    }
    
    // MARK: -- ImageDownloadDelegate methods --
    func imageDownloaded(flickrImage: FlickrImage) {
        DispatchQueue.main.async {
            self.setImage(flickrImage: flickrImage)
        }
    }
}
