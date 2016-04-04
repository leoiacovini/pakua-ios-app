//
//  FeedTableViewController.swift
//  Pakua
//
//  Created by Leonardo Iacovini on 11/03/15.
//  Copyright (c) 2015 Leonardo Iacovini. All rights reserved.
//

import UIKit

var rssCache: [Dictionary<String, String>] = [] // Simple in memory cache for rss feeds

class FeedTableViewController: UITableViewController, FeedParserDelegate {

    var feedParser: FeedParser!
    var feedDic: [Dictionary<String, String>]!
    var destinationURL: NSURL?
    let RSS_URL = NSURL(string: "http://pakuasp.com/rss")!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Reachability.checkAndAlertIfNoConnection(self)
        if rssCache.isEmpty && Reachability.isConnectedToNetwork() {
            feedParser = FeedParser()
            feedParser.delegate = self
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            feedParser.startParsingWithURL(RSS_URL)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func parsingWasFinished() {
        copyToCache()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.navigationItem.title = "Pakua SP Feed"
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rssCache.isEmpty ? 0 : rssCache.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath) as UITableViewCell
        print("Setting Up Cells")
        cell.textLabel?.text = rssCache[indexPath.row]["title"]
        let date = rssCache[indexPath.row]["pubDate"]
        cell.detailTextLabel?.text = getPubDate(date!)
        return cell
    }
    
    
    func getPubDate(date: String) -> String {
        return date.substringToIndex(date.startIndex.advancedBy(17))
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url = rssCache[indexPath.row]["link"]
        destinationURL = NSURL(string: url!)
        let webVC = storyboard?.instantiateViewControllerWithIdentifier("webViewController") as! WebViewController
        webVC.url = destinationURL
        webVC.navigationItem.title = rssCache[indexPath.row]["title"]
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    
    func copyToCache() {
        for item in feedParser.feedDicArray {
            rssCache.append(item)
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let webVC = storyboard?.instantiateViewControllerWithIdentifier("webViewController") as! WebViewController
        webVC.url = destinationURL
    }


}
