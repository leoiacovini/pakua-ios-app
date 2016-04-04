//
//  FeedParser.swift
//  Pakua
//
//  Created by Leonardo Iacovini on 11/03/15.
//  Copyright (c) 2015 Leonardo Iacovini. All rights reserved.
//

import Foundation
import UIKit

protocol FeedParserDelegate {
    func parsingWasFinished()
}

class FeedParser: NSObject, NSXMLParserDelegate {
    
    var xmlParser: NSXMLParser!
    var feedDicArray = [Dictionary<String, String>]()
    var currentFeedDic = Dictionary<String, String>()
    var currentElement = ""
    var foundChars = ""
    
    var delegate: FeedParserDelegate?
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if (currentElement == "title" && currentElement != "Pa-Kua - São Paulo") || currentElement == "link" || currentElement == "pubDate"{
            foundChars += string
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if !foundChars.isEmpty {
            if elementName == "link"{
                foundChars = (foundChars as NSString).substringFromIndex(3)
            }
            currentFeedDic[currentElement] = foundChars
            foundChars = ""
            if currentElement == "pubDate" {
                feedDicArray.append(currentFeedDic)
            }
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        delegate?.parsingWasFinished()
    }
    
    func startParsingWithURL(rssURL: NSURL) {
        NetworkManager.getDataFromURL(rssURL) { (data) in
            if let feedData = data {
                self.xmlParser = NSXMLParser(data: feedData)
                self.xmlParser.delegate = self
                self.xmlParser.parse()
            }
        }
    }

}

