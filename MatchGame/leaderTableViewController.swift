//
//  leaderTableViewController.swift
//  MatchGame
//
//  Created by Yifan Xiao on 5/18/15.
//  Copyright (c) 2015 Yifan Xiao. All rights reserved.
//

import UIKit
import CloudKit

class leaderTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func exitPressed(sender: UIBarButtonItem) {
        
     self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        print("there are \(CloudManager.sharedInstance.arrNotes.count) records")
        return CloudManager.sharedInstance.arrNotes.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("leaderCell", forIndexPath: indexPath) as! leaderCell

        let noteRecord: CKRecord = CloudManager.sharedInstance.arrNotes[indexPath.row]
        
        let score = noteRecord.valueForKey("gameScore") as! NSInteger
        cell.scoreLabel.text = "\(indexPath.row+1).\(score)"

        return cell
    }


}
