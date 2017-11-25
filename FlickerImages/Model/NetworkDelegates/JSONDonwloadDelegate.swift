//
//  JSONDonwloadDelegate.swift
//  FlickerImages
//
//  Created by Abdurrahman Ibrahem Ghanem on 11/21/17.
//  Copyright © 2017 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation

protocol JSONDownloadDelegate {
    
    func JSONDictionaryDownloaded(jsonDict: Dictionary<String,Any>?)
}
