//
//  GameViewController.swift
//  MatchGame
//
//  Created by Yifan Xiao on 5/14/15.
//  Copyright (c) 2015 Yifan Xiao. All rights reserved.
//

import UIKit
import SpriteKit


class GameViewController: UIViewController {
    var scene:GameScene!
    var level: Level!
    
    override func viewDidLoad() {
        super.viewDidLoad()

            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.multipleTouchEnabled = false;
        
            scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .AspectFill
            println("the scene \(scene.size.width), and \(scene.size.height)")
        
            level = Level(filename: "Level_1")
            scene.level = level
        
            scene.addTiles()
        
            skView.presentScene(scene)
        
        
        beginGame()
        
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func beginGame() {
        shuffle()
    }
    
    func shuffle() {
        let newCookies = level.shuffle()
        scene.addSpritesForCookies(newCookies)
    }
}
