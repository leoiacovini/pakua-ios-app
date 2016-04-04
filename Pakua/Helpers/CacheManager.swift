//
//  CacheManager.swift
//  Pakua
//
//  Created by Leonardo Iacovini on 12/03/15.
//  Copyright (c) 2015 Leonardo Iacovini. All rights reserved.
//

import Foundation

class CacheManager {
    
    class func checkIfExists(nome: String) -> Bool {
        let cache: NSFileManager = NSFileManager()
        var path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        path = path.stringByAppendingString("/\(nome)")
        return cache.fileExistsAtPath(path)
    }
    
    class func retriveCache(nome: String) -> AnyObject? {
        if checkIfExists(nome) {
            let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
            return NSData(contentsOfURL: url)
        } else {
            return nil
        }
    }
    
    class func saveDataToCache(nome: String, data: NSData) {
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        data.writeToURL(url, atomically: true)
    }
    
    class func retriveObjectFromCacheOrURL(nome: String, url: NSURL, inout dataContainer: NSData, block: () -> ()) -> AnyObject? {
        if let cachedObject: AnyObject = retriveCache(nome) {
            return cachedObject
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                let dataObject = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if dataObject == nil {
                     print("Sem Dados")
                    } else {
                    dataContainer = dataObject!
                    block()
                    }
                })
                
            })
            return nil
        }
    }
}

