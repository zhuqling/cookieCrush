//
//  menuViewController.swift
//  MatchGame
//
//  Created by Yifan Xiao on 5/18/15.
//  Copyright (c) 2015 Yifan Xiao. All rights reserved.
//

import UIKit
import CloudKit

class menuViewController: UIViewController {
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        NSNotificationCenter.defaultCenter().postNotificationName("tableViewdidLoad", object: self)
        
        addNewRecord()
        
    }
    
    
    func addNewRecord(){
        
        //        let timestampAsString = String(format: "%f", NSDate.timeIntervalSinceReferenceDate())
        //        let timestampParts = timestampAsString.componentsSeparatedByString(".")
        //
        //        let noteID = CKRecordID(recordName: timestampParts[0])
        
        let noteRecord = CKRecord(recordType: "ScoreBoard")
        let score = 1200
        noteRecord.setObject(score, forKey: "gameScore")
        noteRecord.setObject(NSDate(), forKey: "gamePlayedDate")
        
        println(noteRecord)
        
        let container = CKContainer.defaultContainer()
        println(container)
        let publicDatabase = container.publicCloudDatabase
        println(publicDatabase)
        
        publicDatabase.saveRecord(noteRecord, completionHandler: { (record, error) -> Void in
            if (error != nil) {
                println(error)
            }
        })
        
        
    }
    
    @IBAction func startButton(sender: UIButton) {
        
        
    }
    
    @IBAction func leaderBoardButton(sender: UIButton) {
        
        
    }
    
    
    @IBOutlet weak var instructionsButton: UIButton!

}
