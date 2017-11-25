//
//  ImageStash.swift
//  FlickerImages
//
//  Created by Abdurrahman Ibrahem Ghanem on 11/22/17.
//  Copyright © 2017 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation
import UIKit

class ImagesStash: ImageDownloadDelegate {
    
    private var maxImagesAllowedInMemory = 200
    static let sharedInstance = ImagesStash()
    private var imagesDict = Dictionary<ImageKey, FlickrImage>()
    private var delegatesDict = Dictionary<ImageKey, ImageDownloadDelegate>()
    private var imagesQueue = [ImageKey]()
    
    var count: Int {
        return imagesQueue.count
    }
    
    var MaxImagesAllowedInMemory: Int {
        set(newValue) {
            self.maxImagesAllowedInMemory = newValue
        }
        get {
            return maxImagesAllowedInMemory
        }
    }
    
    init() {
        createImagesDirectoryOnDisk()
    }
    
    func removeAll() {
        imagesDict.removeAll()
        delegatesDict.removeAll()
        imagesQueue.removeAll()
    }
    
    func removeImage(flickrImage: FlickrImage, andFromDisk: Bool = false) {
        if let key = flickrImage.imageKey {
            imagesDict.removeValue(forKey: key)
            delegatesDict.removeValue(forKey: key)
            imagesQueue = imagesQueue.filter() { $0 != key }
            
            if andFromDisk {
                self.removeImageFromDisk(flickrImage: flickrImage)
            }
        }
    }
    
    func ignoreDelegateForImage(flickrImage: FlickrImage?) {
        if let imageKey = flickrImage?.imageKey {
            delegatesDict.removeValue(forKey: imageKey)
        }
    }
    
    func removeAllAndSaveToDisk() {
        //Race condition can happen here while saving old images to disk and adding new ones.
        // the new images may also be saved and removed with the old batch
        DispatchQueue.global(qos: .userInitiated).async {
            for (_, img) in self.imagesDict {
                self.spillImageToDisk(flickrImage: img)
            }
            self.removeAll()
        }
    }
    
    private func downloadImage(flickrImage: FlickrImage, delegate: ImageDownloadDelegate) {
        if let key = flickrImage.imageKey {
            let imgOp = ImageNetworkOperation(flickrImage: flickrImage, delegate: self)
            delegatesDict[key] = delegate
            imgOp.start()
        }
    }
    
    func getImage(flickrImage: FlickrImage) -> FlickrImage? {
        
        var image: FlickrImage? = nil
        
        if let key = flickrImage.imageKey {
            if let img = imagesDict[key] {
                image = img
            } else if let img = readImageFromDisk(flickrImage: flickrImage){
                image = img
            }
        }
        
        return image
    }
    
    func getImageDownloadIfNotExistLocally(flickrImage: FlickrImage, delegate: ImageDownloadDelegate) -> FlickrImage? {
        if let img = getImage(flickrImage: flickrImage) {
            return img
        } else {
            downloadImage(flickrImage: flickrImage, delegate: delegate)
        }
        
        return nil
    }
    
    internal func imageDownloaded(flickrImage: FlickrImage) {
        if let key = flickrImage.imageKey {
            imagesDict[key] = flickrImage
            delegatesDict[key]?.imageDownloaded(flickrImage: flickrImage)
            imagesQueue.insert(key, at: 0)
            
            if imagesDict.count > maxImagesAllowedInMemory {
                DispatchQueue.global(qos: .userInitiated).async {
                    for _ in 1...10 {
                        if let lastImgKey = self.imagesQueue.popLast() {
                            if let imgToSpill = self.imagesDict[lastImgKey] {
                                self.spillImageToDisk(flickrImage: imgToSpill)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func spillImageToDisk(flickrImage: FlickrImage) {
        if Configurations.diskCachEnabled {
            if let img_key = flickrImage.imageKey, let img = flickrImage.Image {
                if let data = UIImageJPEGRepresentation(img, 0.9) {
                    let filename = Utils.sharedInstance.getDocumentsDirectory().appendingPathComponent(Configurations.imagesDirectoryName).appendingPathComponent("\(img_key).jpg")
                    try? data.write(to: filename)
                    imagesDict.removeValue(forKey: img_key)
                }
            }
        }
    }
    
    private func readImageFromDisk(flickrImage: FlickrImage) -> FlickrImage? {
        //TODO: this mehtod should be implemented async with Dispatch Queue and the loaded image
        // delivered to a delegate for displaying
        if Configurations.diskCachEnabled {
            if let img_key = flickrImage.imageKey {
                let imgURL = Utils.sharedInstance.getDocumentsDirectory().appendingPathComponent(Configurations.imagesDirectoryName).appendingPathComponent("\(img_key).jpg")
                do {
                    let imageData = try Data(contentsOf: imgURL)
                    flickrImage.Image = UIImage(data: imageData)
                    return flickrImage
                } catch {
                    
                }
            }
        }
        
        return nil
    }
    
    private func removeImageFromDisk(flickrImage: FlickrImage) {
        if let key = flickrImage.imageKey {
            let fileManager = FileManager.default
            let docDir = Utils.sharedInstance.getDocumentsDirectory()
            let imagePath = docDir.appendingPathComponent(Configurations.imagesDirectoryName).appendingPathComponent("\(key).jpg")
            
            do {
                try fileManager.removeItem(atPath: imagePath.path)
            }
            catch {
                
            }
        }
    }
    
    private func createImagesDirectoryOnDisk() {
        let newDir = Utils.sharedInstance.getDocumentsDirectory().appendingPathComponent("images")
        var isDir : ObjCBool = true
        do {
            let fileManager = FileManager.default
            let exists = fileManager.fileExists(atPath: newDir.path, isDirectory:&isDir)
                
            if isDir.boolValue && exists == false {
                try fileManager.createDirectory(atPath: newDir.path, withIntermediateDirectories: true, attributes: nil)
            }
            
        } catch {
            
        } 
    }
    
    deinit {
        self.removeAll()
    }
}
