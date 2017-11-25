//
//  JSONNetworkOperation.swift
//  FlickerImages
//
//  Created by Abdurrahman Ibrahem Ghanem on 11/21/17.
//  Copyright © 2017 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation

class JSONNetworkOperation: NetworkOperationDelegate {
    
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
        self.networkOperation?.start()
    }
    
    private func buildURL(searchKey: SearchKey, page: Int?) -> String? {
        if let encodedSearchKey = searchKey.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            var url = String("https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&format=json&nojsoncallback=1&safe_search=1&text=\(encodedSearchKey)")
            
            if let pg = page {
                url += ((pg > 0) ? "&page=\(pg)" : "&page=1")
            }
            
            return url
        }
        
        return nil
    }
    
    internal func dataReady(data: Data) {
        if data.count > 0 {
            do {
                if let dict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] {
                    jsonDownloadDelegate?.JSONDictionaryDownloaded(jsonDict: dict)
                }
            } catch {
                
            }
        }
    }
    
}
