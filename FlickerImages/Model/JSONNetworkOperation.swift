//
//  JSONNetworkOperation.swift
//  FlickerImages
//
//  Created by Abdurrahman Ibrahem Ghanem on 11/21/17.
//  Copyright © 2017 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation

class JSONNetworkOperation: NetworkOperationDelegate {
    
    private let api_key = "758363a8f3935bdd86eca9f52c0ae233"
    private let defaultNetworkConnectionTimeout = 10
    private var networkOperation: NetworkOperation? = nil
    private var dictionary: Dictionary<String,Any>? = nil
    private var jsonDownloadDelegate: JSONDownloadDelegate? = nil
    
    init(searchKey: SearchKey, page: Int?, delegate: JSONDownloadDelegate) {
        if let url = self.buildURL(searchKey: searchKey, page: page) {
            self.networkOperation = NetworkOperation(url: url, delegate: self, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeout: defaultNetworkConnectionTimeout)
            self.jsonDownloadDelegate = delegate
        }
    }
    
    func start() {
        self.networkOperation?.start(priority: 1.0)
    }
    
    private func buildURL(searchKey: SearchKey, page: Int?) -> String? {
        if let encodedSearchKey = searchKey.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            var url = String("https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(api_key)&format=json&nojsoncallback=1&safe_search=1&text=\(encodedSearchKey)")
            
            if let pg = page {
                url += ((pg > 0) ? "&page=\(pg)" : "&page=1")
            }
            
            return url
        }
        
        return nil
    }
    
    internal func dataReady(data: Data?) {
        if data != nil && data!.count > 0 {
            do {
                if let dict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:Any] {
                    jsonDownloadDelegate?.JSONDictionaryDownloaded(jsonDict: dict)
                    return
                }
            } catch {
                //TODO: handle image index download failure
            }
        }
        
        jsonDownloadDelegate?.JSONDictionaryDownloaded(jsonDict: nil)
    }
    
}
