//
//  CloudManager.swift
//  MatchGame
//
//  Created by Yifan Xiao on 5/18/15.
//  Copyright (c) 2015 Yifan Xiao. All rights reserved.
//

import UIKit
import CloudKit

class CloudManager: NSObject {
    
    
    static let sharedInstance = CloudManager()
    
    var arrNotes: Array<CKRecord> = []
    
   
    func getData(){
    let container = CKContainer.defaultContainer()
    let publicDatabase = container.publicCloudDatabase
    let predicate = NSPredicate(value: true)
    
    let query = CKQuery(recordType: "ScoreBoard", predicate: predicate)
    
    let scoreSort = NSSortDescriptor(key: "gameScore", ascending: false)
        query.sortDescriptors = [scoreSort]
    
        publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
                if error != nil {
                println(error)
            }
            else {
                    println(results)
    
                        for result in results {
                            self.arrNotes.append(result as! CKRecord)
                        }
    
    NSNotificationCenter.defaultCenter().postNotificationName("tableViewdidLoad", object: self)
    
                }
        }
    }
    
    
    
    
    
    
}
