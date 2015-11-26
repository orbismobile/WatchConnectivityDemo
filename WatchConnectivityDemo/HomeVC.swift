//
//  ViewController.swift
//  WatchConnectivityDemo
//
//  Created by Erik Flores on 11/26/15.
//  Copyright © 2015 orbis. All rights reserved.
//

import UIKit
import WatchConnectivity

class HomeVC: UIViewController, WCSessionDelegate {
    
    //Default User
    var items = [String]()
    var defaultDataUser = NSUserDefaults.standardUserDefaults()
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Watch Connection
    private let session: WCSession? = WCSession.isSupported() ?  WCSession.defaultSession() : nil
    
    private var validSession: WCSession? {
        if let session = session where session.paired && session.watchAppInstalled {
            return session
        }
        return nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureWCSession()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureWCSession()
    }
    
    private func configureWCSession() {
        session?.delegate = self
        session?.activateSession()
    }
    
    // MARK: Start Application
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.defaultDataUser.objectForKey("DataUser") != nil {
            self.items = self.defaultDataUser.objectForKey("DataUser")! as! [String]
            self.tableView.reloadData()
            self.sendData()
        }
    }
    
    // MARK: Send Item to Watch
    @IBAction func addItem(sender: AnyObject) {
        let addItemAlertController = UIAlertController(title: "Item", message: "Add Item", preferredStyle: .Alert) as UIAlertController
        let addItemAlertAction = UIAlertAction(title: "OK", style: .Default) { (UIAlertAction) -> Void in
            let textField = addItemAlertController.textFields![0] as UITextField
            let messageText = textField.text!
            self.items.append(messageText)
            self.tableView.reloadData()
            self.sendTextDataToWatch(messageText)
            self.defaultDataUser.setObject(self.items, forKey: "DataUser")
            self.sendData()
            
            print("After dataUser \(self.defaultDataUser.objectForKey("DataUser")!)")
        }
        addItemAlertController.addAction(addItemAlertAction)
        addItemAlertController.addTextFieldWithConfigurationHandler { (UITextField) -> Void in }
        self.presentViewController(addItemAlertController, animated: true) { () -> Void in }
    }
    
    
    func sendTextDataToWatch(messageText: String) -> Void {
        let applicationData = ["message" : messageText]
        if let session = session where session.reachable {
            session.sendMessage(applicationData,
                replyHandler: { replyData in
                    print(replyData)
                }, errorHandler: { error in
                    print(error)
            })
        } else {
            // when the iPhone is not connected via Bluetooth
        }
    }
    
    /*func sendData() -> Void {
    do {
    let applicationDict = ["appContext":self.defaultDataUser.objectForKey("DataUser")!]
    WCSession.defaultSession().transferUserInfo(applicationDict)
    }
    }*/
    
    func sendData() -> Void {
        do{
            let applicationDict = ["appContext":self.defaultDataUser.objectForKey("DataUser")!]
            try WCSession.defaultSession().updateApplicationContext(applicationDict)
            
        } catch {}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

// MARK: Table View Data Source
extension HomeVC: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let homeTableCell = tableView.dequeueReusableCellWithIdentifier("homeItemCell") as UITableViewCell!
        homeTableCell.textLabel?.text = items[indexPath.row]
        return homeTableCell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            items.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            let dataItem = ["item":indexPath.row]
            if let session = session where session.reachable {
                session.sendMessage(dataItem, replyHandler: { (replayData) -> Void in
                    
                    }, errorHandler: { (error) -> Void in
                        
                })
            }
            
            self.defaultDataUser.setObject(self.items, forKey: "DataUser")
            print("after delete userData \(self.defaultDataUser.objectForKey("DataUser")!)")
        }
    }
    
}
