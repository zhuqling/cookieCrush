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
        
        CloudManager.sharedInstance.getData()
    }
    
    @IBAction func startButton(sender: UIButton) {
        
        
    }
    
    @IBAction func leaderBoardButton(sender: UIButton) {
        
        
    }
    
    
    @IBOutlet weak var instructionsButton: UIButton!
    

}
