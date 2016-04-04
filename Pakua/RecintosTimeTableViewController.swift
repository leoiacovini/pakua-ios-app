//
//  RecintosTimeTableViewController.swift
//  Pakua
//
//  Created by Leonardo Iacovini on 12/03/15.
//  Copyright (c) 2015 Leonardo Iacovini. All rights reserved.
//

import UIKit

class RecintosTimeTableViewController: UITableViewController {

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        performSegueWithIdentifier("timeTableSegue", sender: self)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let timeTableVC = segue.destinationViewController as! TimeTableViewController
        var recintoStr = tableView.cellForRowAtIndexPath(tableView.indexPathForSelectedRow!)?.textLabel?.text?.lowercaseString
        if recintoStr == "tatuapé" {
            recintoStr = "tatuape"
        } else if recintoStr == "saúde" {
            recintoStr = "saude1"
        } else if recintoStr == "saúde 2" {
            recintoStr = "saude2"
        }
        timeTableVC.recinto = recintoStr
    }

}
