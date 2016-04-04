//
//  ViewController.swift
//  Pakua
//
//  Created by Leonardo Iacovini on 2/13/15.
//  Copyright (c) 2015 Leonardo Iacovini. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    var url: NSURL?
    @IBOutlet var loadSpinner: UIActivityIndicatorView!
    @IBOutlet var webView: UIWebView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var indexAdress: NSURLRequest!
        Reachability.checkAndAlertIfNoConnection(self)
        webView.delegate = self
        if Reachability.isConnectedToNetwork() {
            if url == nil {
                indexAdress = NSURLRequest(URL: NSURL(string: "http://pakuasp.com/")!)
            } else {
                indexAdress = NSURLRequest(URL: url!)
            }
            self.webView.loadRequest(indexAdress)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        loadSpinner.stopAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        loadSpinner.startAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loadSpinner.stopAnimating()
        loadSpinner.hidesWhenStopped = true
        UIApplication.sharedApplication().networkActivityIndicatorVisible  = false
    }

}

