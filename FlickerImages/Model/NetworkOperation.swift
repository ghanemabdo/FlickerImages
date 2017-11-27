//
//  NetworkOperation.swift
//  FlickerImages
//
//  Created by Abdurrahman Ibrahem Ghanem on 11/21/17.
//  Copyright © 2017 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation

class NetworkOperation {
    
    static private var queue = initQueue()
    private let delegate: NetworkOperationDelegate
    private let request: URLRequest?
    
    static func initQueue() -> OperationQueue {
        let oq = OperationQueue()
        oq.maxConcurrentOperationCount = 10
        
        return oq
    }
    
    init (url: String, delegate: NetworkOperationDelegate, cachePolicy: URLRequest.CachePolicy, timeout: Int) {
                
        self.delegate = delegate
        if let urlObj = URL(string: url) {
            self.request = URLRequest(url: urlObj, cachePolicy: cachePolicy, timeoutInterval: TimeInterval(timeout))
        } else {
            self.request = nil
        }
    }
    
    func start(priority: Float = 0.5) {
        if self.request != nil {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: NetworkOperation.queue)
            let task = session.dataTask(with: self.request!, completionHandler: { data, response, error -> Void in
                self.delegate.dataReady(data: data)
                
                if error != nil {
                    //TODO: handle network error
                    
                }
            })
            
            task.priority = priority
            task.resume()
        }
    }
}
