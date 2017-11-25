//
//  NetworkOperation.swift
//  FlickerImages
//
//  Created by Abdurrahman Ibrahem Ghanem on 11/21/17.
//  Copyright © 2017 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation

class NetworkOperation {
    
    private let delegate: NetworkOperationDelegate
    private let request: URLRequest?
    
    init (url: String, delegate: NetworkOperationDelegate, cachePolicy: URLRequest.CachePolicy, timeout: Int) {
        self.delegate = delegate
        if let urlObj = URL(string: url) {
            self.request = URLRequest(url: urlObj, cachePolicy: cachePolicy, timeoutInterval: TimeInterval(timeout))
        } else {
            self.request = nil
        }
    }
    
    func start() {
        if self.request != nil {
            let task = URLSession.shared.dataTask(with: request!, completionHandler: { data, response, error -> Void in
                if data != nil {
                    self.delegate.dataReady(data: data!)
                } else if error != nil {
                    
                }
            })
            
            task.resume()
        }
    }
}
