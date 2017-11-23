//
//  ImageStash.swift
//  FlickerImages
//
//  Created by Abdurrahman Ibrahem Ghanem on 11/22/17.
//  Copyright © 2017 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation
import UIKit

class ImageStash: ImageDownloadDelegate {
    
    let maxImagesAllowedInMemory = 200
    static let sharedInstance = ImageStash()
    var imagesDict = Dictionary<ImageKey, FlickrImage>()
    var delegatesDict = Dictionary<ImageKey, ImageDownloadDelegate>()
    var imagesQueue = Queue<ImageKey>()
    
    init() {
        createImagesDirectoryOnDisk()
    }
    
    func removeAll() {
        imagesDict.removeAll()
        delegatesDict.removeAll()
        imagesQueue.removeAll()
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
    
    func downloadImage(flickrImage: FlickrImage, delegate: ImageDownloadDelegate) {
        if let key = flickrImage.imageKey {
            let imgOp = ImageNetworkOperation(flickrImage: flickrImage, delegate: self)
            delegatesDict[key] = delegate
            imgOp.start()
        }
    }
    
    func getImage(flickrImage: FlickrImage) -> FlickrImage? {
        if let key = flickrImage.imageKey {
            return imagesDict[key]
        } else if let img = readImageFromDisk(flickrImage: flickrImage){
            return img
        } 
        
        return nil
    }
    
    func getImageDownloadIfNotExistLocally(flickrImage: FlickrImage, delegate: ImageDownloadDelegate) -> FlickrImage? {
        if let img = getImage(flickrImage: flickrImage) {
            return img
        } else {
            downloadImage(flickrImage: flickrImage, delegate: delegate)
        }
        
        return nil
    }
    
    func imageDownloaded(flickrImage: FlickrImage) {
        if let key = flickrImage.imageKey {
            imagesDict[key] = flickrImage
            delegatesDict[key]?.imageDownloaded(flickrImage: flickrImage)
            imagesQueue.enqueue(key)
            
            if imagesDict.count > maxImagesAllowedInMemory {
                DispatchQueue.global(qos: .userInitiated).async {
                    for _ in 1...10 {
                        if let lastImgKey = self.imagesQueue.dequeue() {
                            if let imgToSpill = self.imagesDict[lastImgKey] {
                                self.spillImageToDisk(flickrImage: imgToSpill)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func spillImageToDisk(flickrImage: FlickrImage) {
        if let img_key = flickrImage.imageKey, let img = flickrImage.image {
            if let data = UIImageJPEGRepresentation(img, 0.9) {
                let filename = Utils.sharedInstance.getDocumentsDirectory().appendingPathComponent("\(img_key).jpg")
                try? data.write(to: filename)
                imagesDict.removeValue(forKey: img_key)
            }
        }
    }
    
    func readImageFromDisk(flickrImage: FlickrImage) -> FlickrImage? {
        //TODO: this mehtod should be implemented async with Dispatch Queue and the loaded image
        // delivered to a delegate for displaying
        if let img_key = flickrImage.imageKey {
            let imgURL = Utils.sharedInstance.getDocumentsDirectory().appendingPathComponent("\(img_key).jpg")
            do {
                let imageData = try Data(contentsOf: imgURL)
                flickrImage.Image = UIImage(data: imageData)
                return flickrImage
            } catch {
                print("Error loading image : \(error)")
            }
        }
        
        return nil
    }
    
    func createImagesDirectoryOnDisk() {
        let newDir = Utils.sharedInstance.getDocumentsDirectory().appendingPathComponent("images")
        var isDir : ObjCBool = true
        do {
            let fileManager = FileManager.default
            let exists = fileManager.fileExists(atPath: newDir.path, isDirectory:&isDir)
                
            if isDir.boolValue && exists == false {
                try fileManager.createDirectory(atPath: newDir.path, withIntermediateDirectories: true, attributes: nil)
            }
            
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        } 
    }
}
