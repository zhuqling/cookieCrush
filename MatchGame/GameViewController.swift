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
    var movesLeft = 0
    var score = 0
    
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var gameEndView: UIImageView!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    var scene:GameScene!
    var level: Level!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            self.gameEndView.hidden = true
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
            //init the level instance to assgin the property
        
            scene.addTiles()
        
            scene.swipeHandler = handleSwipe
        //
        //
        //connect the handler
        //
        //
        //
        
            skView.presentScene(scene)
        
        
        beginGame()
        
        
    }
    
    
    @IBAction func shuffleButtonTapped(sender: UIButton) {
        
        shuffle()
        decrementMoves()
    }
    
    
    @IBAction func menuButtonTapped(sender: UIButton) {
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    func showGameEnd() {
        
        self.shuffleButton.hidden = true
        self.menuButton.hidden = true
        
        self.gameEndView.hidden = false
        scene.userInteractionEnabled = false
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideGameEnd")
        view.addGestureRecognizer(tapGestureRecognizer)
        
        
        
    }
    
    func hideGameEnd() {
        self.view.removeGestureRecognizer(tapGestureRecognizer)
        self.tapGestureRecognizer = nil
        
        self.gameEndView.hidden = true
        scene.userInteractionEnabled = true
        
        beginGame()
    }
    
    func updateLabels() {
        targetLabel.text = String(format: "%ld", level.targetScore)
        movesLabel.text = String(format: "%ld", movesLeft)
        scoreLabel.text = String(format: "%ld", score)
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
        
        movesLeft = level.maximumMoves
        score = 0
        updateLabels()
        
        shuffle()
        
       
            self.shuffleButton.hidden = false
            self.menuButton.hidden = false
        
    }
    
    func shuffle() {
        
        scene.removeAllCookieSprites()
        
        let newCookies = level.shuffle()
        scene.addSpritesForCookies(newCookies)
    }
    
    func handleSwipe(swap: Swap) {
        view.userInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            scene.animateSwap(swap, completion: handleMatches)
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.userInteractionEnabled = true
            }
        }
    }
    
    func handleMatches() {
        
        let lines = level.removeMatches()
        
        // If there are no more matches, then the player gets to move again.
        if lines.count == 0 {
            beginNextTurn()
            return
        }
        
        
        scene.animateMatchedCookies(lines) {
            
            
            for line in lines {
                self.score += line.points
            }
            self.updateLabels()
            
            
            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies(columns) {
                let columns = self.level.topUpCookies()
                self.scene.animateNewCookies(columns) {
                    
                    self.handleMatches()
                    
                }
            }
        }
    }
    
    func beginNextTurn() {
        //level.resetComboMultiplier()
        level.detectPossibleSwaps()
        view.userInteractionEnabled = true
        decrementMoves()
    }
    
    func decrementMoves() {
        --movesLeft
        updateLabels()
        
        if score >= level.targetScore {
            self.gameEndView.image = UIImage(named: "LevelComplete")
            showGameEnd()
        } else if movesLeft == 0 {
            self.gameEndView.image = UIImage(named: "GameOver")
            showGameEnd()
        }
    }
}
