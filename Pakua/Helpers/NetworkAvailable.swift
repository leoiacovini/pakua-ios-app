//
//  NetworkAvailable.swift
//  Pakua
//
//  Created by Leonardo Iacovini on 12/03/15.
//  Copyright (c) 2015 Leonardo Iacovini. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit

public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    class func checkAndAlertIfNoConnection(sender: AnyObject) {
        
        if !Reachability.isConnectedToNetwork() {
            let alert = UIAlertController(title: "Sem Internet", message: "Você não está conectado à internet, alguns serviços não estarão disponivéis", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(okAction)
            sender.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
}



