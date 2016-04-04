//
//  NetworkManager.swift
//  PakuaSP
//
//  Created by Leonardo Iacovini on 4/4/16.
//  Copyright © 2016 Leonardo Iacovini. All rights reserved.
//

import Foundation

class NetworkManager {
    
    class func getDataFromURL(url: NSURL, block: (data: NSData?) -> ()) {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        NSURLSession(configuration: config).dataTaskWithURL(url) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), { 
                    block(data: data)
            })
        }.resume()
    }
}