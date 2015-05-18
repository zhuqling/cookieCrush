//
//  menuViewController.swift
//  MatchGame
//
//  Created by Yifan Xiao on 5/18/15.
//  Copyright (c) 2015 Yifan Xiao. All rights reserved.
//

import UIKit

class menuViewController: UIViewController {
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        NSNotificationCenter.defaultCenter().postNotificationName("tableViewdidLoad", object: self)
    }
    
    @IBAction func startButton(sender: UIButton) {
        
        
    }
    
    @IBAction func leaderBoardButton(sender: UIButton) {
        
        
    }
    
    
    @IBOutlet weak var instructionsButton: UIButton!

}
