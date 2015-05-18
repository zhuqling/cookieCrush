//
//  GameViewController.swift
//  MatchGame
//
//  Created by Yifan Xiao on 5/14/15.
//  Copyright (c) 2015 Yifan Xiao. All rights reserved.
//

import UIKit
import SpriteKit
import CloudKit


class GameViewController: UIViewController {
    var movesLeft = 0
    var score = 0
    
    var arrNotes: Array<CKRecord> = []

    
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
        
        getBoard()
        
        if arrNotes.count<5{
            addNewRecord()
        }
        else{
            
            updateRecords()
            addNewRecord()
            
        }
        
    }
    
    
    func updateRecords(){
        
        var min = NSInteger.max
        var recordid:CKRecordID?
        
        for record in arrNotes as [CKRecord]!{
           let recordScore = record.valueForKey("gameScore") as? NSInteger
            
            if recordScore < min{
                min = recordScore!
                recordid = record.recordID
            }
        }
        
        if score >= min && recordid != nil{
            
            let container = CKContainer.defaultContainer()
            let publicDatabase = container.publicCloudDatabase
            
            publicDatabase.deleteRecordWithID(recordid, completionHandler: { (recordID, error) -> Void in
                if error != nil {
                    println(error)
                }
            })
            
        }
        
    }
    
    func addNewRecord(){
        
//        let timestampAsString = String(format: "%f", NSDate.timeIntervalSinceReferenceDate())
//        let timestampParts = timestampAsString.componentsSeparatedByString(".")
//        
//        let noteID = CKRecordID(recordName: timestampParts[0])
        
        let noteRecord = CKRecord(recordType: "ScoreBoard")
        
        noteRecord.setObject(score, forKey: "gameScore")
        noteRecord.setObject(NSDate(), forKey: "gamePlayedDate")
        
        println(noteRecord)
        
        let container = CKContainer.defaultContainer()
        let publicDatabase = container.publicCloudDatabase
        
        publicDatabase.saveRecord(noteRecord, completionHandler: { (record, error) -> Void in
            if (error != nil) {
                println(error)
            }
        })

        
    }
    
    
    func getBoard(){
        
        self.arrNotes = []
        
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
