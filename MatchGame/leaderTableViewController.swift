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

    var arrNotes: Array<CKRecord> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
            let container = CKContainer.defaultContainer()
            let publicDatabase = container.publicCloudDatabase
            let predicate = NSPredicate(value: true)
            
            let query = CKQuery(recordType: "ScoreBoard", predicate: predicate)
            
            
            publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
                if error != nil {
                    println(error)
                }
                else {
                    println(results)
                    
                    for result in results {
                        self.arrNotes.append(result as! CKRecord)
                    }
                    
                }
            }
        
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
        return arrNotes.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("leaderCell", forIndexPath: indexPath) as! UITableViewCell

        let noteRecord: CKRecord = arrNotes[indexPath.row]
        
        cell.textLabel?.text = noteRecord.valueForKey("gameScore") as? String
        cell.detailTextLabel?.text = noteRecord.valueForKey("gamePlayedDate") as? String

        return cell
    }


}
