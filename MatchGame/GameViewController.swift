
import UIKit
import SpriteKit
import CloudKit
import AVFoundation


class GameViewController: UIViewController {
    var movesLeft = 0 // 可用步数
    var score = 0 // 总分
    
    @IBOutlet weak var targetLabel: UILabel! // 目标分
    @IBOutlet weak var movesLabel: UILabel! // 步数
    @IBOutlet weak var scoreLabel: UILabel! // 总分
    
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var gameEndView: UIImageView!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    var scene:GameScene!
    var level: Level!
    
    var backgroundMusic: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameEndView.hidden = true
        
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.multipleTouchEnabled = false;
//        skView.ignoresSiblingOrder = true;
        
        // 加载关卡
        level = Level(filename: "Level_1")
    
        // 初始场景
        scene = GameScene(size: skView.bounds.size, level:level)
        scene.scaleMode = .AspectFill
        print("the scene \(scene.size.width), and \(scene.size.height)")
    
        //init the level instance to assgin the property
    
        scene.addTiles()
        scene.swipeHandler = handleSwipe
        skView.presentScene(scene)
        
        // 音效
        if let url = NSBundle.mainBundle().URLForResource("Mining by Moonlight", withExtension: "mp3") {
            self.backgroundMusic = try! AVAudioPlayer(contentsOfURL: url)
            self.backgroundMusic.numberOfLoops = -1;
            self.backgroundMusic.play()
        }
        
        beginGame()
    }
    
    
    @IBAction func shuffleButtonTapped(sender: UIButton) {
        shuffle()
        decrementMoves() // 减少步数
    }
    
    @IBAction func menuButtonTapped(sender: UIButton) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func showGameEnd() {
        scene.animateGameOver() // 动效
        
        self.shuffleButton.hidden = true
        self.menuButton.hidden = true
        
        self.gameEndView.hidden = false
        scene.userInteractionEnabled = false
        
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameViewController.hideGameEnd))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        if CloudManager.sharedInstance.arrNotes.count<5{
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
        
        for record in CloudManager.sharedInstance.arrNotes as [CKRecord]!{
           let recordScore = record.valueForKey("gameScore") as? NSInteger
            
            if recordScore < min{
                min = recordScore!
                recordid = record.recordID
            }
        }
        
        if score >= min && recordid != nil{
            
            let container = CKContainer.defaultContainer()
            let publicDatabase = container.publicCloudDatabase
            
            publicDatabase.deleteRecordWithID(recordid!, completionHandler: { (recordID, error) -> Void in
                if error != nil {
                    print(error)
                }
            })
            
        }
        
    }
    
    func addNewRecord(){
        
        let noteRecord = CKRecord(recordType: "ScoreBoard")
        
        noteRecord.setObject(score, forKey: "gameScore")
        noteRecord.setObject(NSDate(), forKey: "gamePlayedDate")
        
        
        let container = CKContainer.defaultContainer()
        let publicDatabase = container.publicCloudDatabase
        
        publicDatabase.saveRecord(noteRecord, completionHandler: { (record, error) -> Void in
            if (error != nil) {
                print(error)
            }
            else{
                CloudManager.sharedInstance.arrNotes.append(noteRecord)
            }
        })
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
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.AllButUpsideDown
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func beginGame() {
        // 复位
        movesLeft = level.maximumMoves
        score = 0
        updateLabels()
        
        level.resetComboMultiplier() // 复位连击
        scene.animateBeginGame() // 动效
        shuffle() // 随机生成新元素
        
        self.shuffleButton.hidden = false
        self.menuButton.hidden = false
    }
    
    // 随机
    func shuffle() {
        let newCookies = level.shuffle()
        
        scene.removeAllCookieSprites() // 先清除原有的所有元素
        scene.addSpritesForCookies(newCookies)
    }
    
    // 手势
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
    
    // 处理匹配
    func handleMatches() {
        let lines = level.removeMatches() // 查找匹配元素
        
        // 未找到匹配时，激活用户交互
        if lines.count == 0 {
            beginNextTurn()
            return
        }
        
        // 移除动效
        scene.animateMatchedCookies(lines) {
            // 计分
            for line in lines {
                self.score += line.points
            }
            self.updateLabels()
            
            let columns = self.level.fillHoles() // 填洞，将上面的掉落到空位
            self.scene.animateFallingCookies(columns) { // 掉落动效
                let columns = self.level.topUpCookies() // 填充新元素
                self.scene.animateNewCookies(columns) { // 新元素动效
                    self.handleMatches() // 反复检测是否有新匹配
                }
            }
        }
    }
    
    func beginNextTurn() {
        level.resetComboMultiplier() // 复位连击
        
        level.detectPossibleSwaps()
        
        view.userInteractionEnabled = true
        
        decrementMoves() // 减少步数
    }
    
    // 减少可用步数
    func decrementMoves() {
        movesLeft -= 1
        updateLabels()
        
        // 检查是否过关或者失败
        if score >= level.targetScore {
            self.gameEndView.image = UIImage(named: "LevelComplete")
            showGameEnd()
        } else if movesLeft == 0 {
            self.gameEndView.image = UIImage(named: "GameOver")
            showGameEnd()
        }
    }
}
