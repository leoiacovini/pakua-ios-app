//
//  MainTableViewController.swift
//  Pakua
//
//  Created by Leonardo Iacovini on 2/13/15.
//  Copyright (c) 2015 Leonardo Iacovini. All rights reserved.
//

import UIKit
import MessageUI

class MainTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.barTintColor = UIColor.yellowColor()
        self.navigationController!.navigationBar.backgroundColor = UIColor.redColor()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text == "Contato" {
            presentModalMailComposeViewController(true)
        }
        tableView.cellForRowAtIndexPath(indexPath)!.selected = false
    }
    
    func presentModalMailComposeViewController(animated: Bool) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.setSubject("Contato PakuaApp")
            mailComposeVC.setToRecipients(["leoiacovini@gmail.com"])
            presentViewController(mailComposeVC, animated: animated, completion: nil)
        } else {
            UIAlertView(title: NSLocalizedString("Error", value: "Error", comment: ""), message: NSLocalizedString("Your device doesn't support Mail messaging", value: "Your device doesn't support Mail messaging", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", value: "OK", comment: "")).show()
        }
    }
    
    //MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        if error != nil {
            print("Error: \(error)")
        }
        dismissViewControllerAnimated(true, completion: nil)
    }


}
