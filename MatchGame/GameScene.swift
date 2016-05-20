/*
 * 场景
 */

import SpriteKit

class GameScene: SKScene {
    var level: Level!
    
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let cookiesLayer = SKNode() // 元素
    let tilesLayer = SKNode() // 贴砖
    
    // 边角处理
    let cropLayer = SKCropNode()
    let maskLayer = SKNode()
    
    var swipeFromColumn: Int?
    var swipeFromRow: Int?
    
    var swipeHandler: ((Swap) -> ())?
    
    var selectionSprite = SKSpriteNode() // 选中元素，用于高亮
    
    let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
    let invalidSwapSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false)
    let fallingCookieSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false)
    let addCookieSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false)
    
    // MARK: - init
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    init(size: CGSize, level: Level) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let background = SKSpriteNode(imageNamed: "Background")
//        print("node size \(background.size.width), and \(background.size.height)")
        addChild(background)
        
        gameLayer.hidden = true
        addChild(gameLayer)
        
        let layerPosition = CGPointMake(-TileWidth * CGFloat(level.NumColumns) / 2, -TileHeight * CGFloat(level.NumRows) / 2)
        
        tilesLayer.position = layerPosition
        gameLayer.addChild(tilesLayer)
        
        // 边角处理层
        gameLayer.addChild(cropLayer)
        
        maskLayer.position = layerPosition;
        cropLayer.maskNode = maskLayer
        
        cookiesLayer.position = layerPosition
        cropLayer.addChild(cookiesLayer)
        
        swipeFromColumn = nil
        swipeFromRow = nil
        
        self.level = level
    }
    
    // MARK: - Game setup
    
    // 初始化贴砖
    func addTiles() {
        for row in 0..<level.NumRows {
            for column in 0..<level.NumColumns {
                if level.tileAtColumn(column, row: row) != nil {
                    let tileNode = SKSpriteNode(imageNamed: "MaskTile")
                    tileNode.position = pointForColumn(column, row: row)
                    maskLayer.addChild(tileNode)
                }
            }
        }
        
        // The tile pattern is drawn *in between* the level tiles. That's why
        // there is an extra column and row of them.
        for row in 0...level.NumRows {
            for column in 0...level.NumColumns {
                let topLeft = Int(column > 0 && row < level.NumRows && level.tileAtColumn(column - 1, row:row) != nil)
                let bottomLeft = Int(column > 0 && row > 0 && level.tileAtColumn(column - 1, row:row - 1) != nil)
                let topRight = Int(column < level.NumColumns && row < level.NumRows && level.tileAtColumn(column, row:row) != nil)
                let bottomRight = Int(column < level.NumColumns && row > 0 && level.tileAtColumn(column, row:row - 1) != nil)
                
                // The tiles are named from 0 to 15, according to the bitmask that is
                // made by combining these four values.
                let value = topLeft | topRight << 1 | bottomLeft << 2 | bottomRight << 3;
                
                // Values 0 (no tiles), 6 and 9 (two opposite tiles) are not drawn.
                if value != 0 && value != 6 && value != 9 {
                    let name = String(format: "Tile_%lu", value)
                    
                    let tileNode = SKSpriteNode(imageNamed: name)
                    
                    var point = self.pointForColumn(column, row:row)
                    point.x -= TileWidth/2
                    point.y -= TileHeight/2
                    tileNode.position = point
                    self.tilesLayer.addChild(tileNode)
                }
            }
        }
    }
    
    // 初始元素Sprite
    func addSpritesForCookies(cookies: Set<Cookie>) {
        for cookie in cookies {
            let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            sprite.position = pointForColumn(cookie.column, row:cookie.row)
            cookiesLayer.addChild(sprite)
            cookie.sprite = sprite
            
            // 动效
            sprite.alpha = 0
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.runAction(SKAction.sequence([
                SKAction.waitForDuration(0.25, withRange: 0.5),
                SKAction.group([
                    SKAction.fadeInWithDuration(0.25),
                    SKAction.scaleTo(1.0, duration: 0.25)
                    ])
                ]))
        }
    }
    
    func removeAllCookieSprites() {
        cookiesLayer.removeAllChildren()
    }
    
    // MARK: - 手势检测
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInNode(cookiesLayer)

        let (success, column, row) = convertPoint(location)
        if success {
            if let cookie = level.cookieAtColumn(column, row: row) {
                showSelectionIndicatorForCookie(cookie)
                
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if swipeFromColumn == nil { return }
        
        let touch = touches.first!
        let location = touch.locationInNode(cookiesLayer)
        
        let (success, column, row) = convertPoint(location)
        if success {
            var horzDelta = 0, vertDelta = 0
            if column < swipeFromColumn! {          // swipe left
                horzDelta = -1
            } else if column > swipeFromColumn! {   // swipe right
                horzDelta = 1
            } else if row < swipeFromRow! {         // swipe down
                vertDelta = -1
            } else if row > swipeFromRow! {         // swipe up
                vertDelta = 1
            }
            
            if horzDelta != 0 || vertDelta != 0 {
                trySwapHorizontal(horzDelta, vertical: vertDelta)
                
                hideSelectionIndicator() // 取消高亮选中
                swipeFromColumn = nil
                swipeFromRow = nil
            }
        }
    }
    
    // 尝试交换位置
    func trySwapHorizontal(horzDelta: Int, vertical vertDelta: Int) {
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta
        
        if toColumn < 0 || toColumn >= level.NumColumns { return }
        if toRow < 0 || toRow >= level.NumRows { return }
        
        if let toCookie = level.cookieAtColumn(toColumn, row: toRow),
            let fromCookie = level.cookieAtColumn(swipeFromColumn!, row: swipeFromRow!),
            let handler = swipeHandler
        {
            let swap = Swap(cookieA: fromCookie, cookieB: toCookie)
            handler(swap)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swipeFromColumn = nil
        swipeFromRow = nil
        
        if selectionSprite.parent != nil {
            hideSelectionIndicator()
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touchesEnded(touches!, withEvent: event)
    }
    
    // MARK: - 选中高亮
    
    // 高亮选中元素
    func showSelectionIndicatorForCookie(cookie: Cookie) {
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }
        
        if let sprite = cookie.sprite {
            let texture = SKTexture(imageNamed: cookie.cookieType.highlightedSpriteName)
            selectionSprite.size = texture.size()
            selectionSprite.runAction(SKAction.setTexture(texture))
            
            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
        }
    }
    
    // 取消高亮
    func hideSelectionIndicator() {
        selectionSprite.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(0.3),
            SKAction.removeFromParent()]))
    }
    
    // MARK: - Animations
    
    // 动效交换
    func animateSwap(swap: Swap, completion: () -> ()) {
        runAction(swapSound)
        
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let duration: NSTimeInterval = 0.3
        
        let moveA = SKAction.moveTo(spriteB.position, duration: duration)
        moveA.timingMode = .EaseOut
        spriteA.runAction(moveA, completion: completion)
        
        let moveB = SKAction.moveTo(spriteA.position, duration: duration)
        moveB.timingMode = .EaseOut
        spriteB.runAction(moveB)
    }
    
    // 动效无效交换
    func animateInvalidSwap(swap: Swap, completion: () -> ()) {
        runAction(invalidSwapSound)
        
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!
        
        spriteA.zPosition = 100
        spriteB.zPosition = 90
        
        let Duration: NSTimeInterval = 0.2
        
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        
        spriteA.runAction(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.runAction(SKAction.sequence([moveB, moveA]))
    }
    
    // 动效移除匹配元素
    func animateMatchedCookies(lines: Set<Line>, completion: () -> ()) {
        for line in lines {
            self.animateScoreForChain(line) // 动效每个匹配的分值
            
            for cookie in line.cookies {
                if let sprite = cookie.sprite {
                    if sprite.actionForKey("removing") == nil {
                        let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
                        scaleAction.timingMode = .EaseOut
                        sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]), withKey:"removing")
                    }
                }
            }
        }
        
        // 音效并稍等后返回
        runAction(matchSound)
        runAction(SKAction.waitForDuration(0.3), completion: completion)
    }
    
    // 动效掉落元素
    func animateFallingCookies(columns: [[Cookie]], completion: () -> ()) {
        var longestDuration: NSTimeInterval = 0
        
        for array in columns {
            for (idx, cookie) in array.enumerate() {
                let newPosition = pointForColumn(cookie.column, row: cookie.row)

                let delay = 0.05 + 0.15 * NSTimeInterval(idx)

                let sprite = cookie.sprite!
                let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)

                longestDuration = max(longestDuration, duration + delay)

                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.runAction(SKAction.sequence([
                    SKAction.waitForDuration(delay),
                    SKAction.group([moveAction, fallingCookieSound])
                ]))
            }
        }
        
        // 等待动效完成后返回
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }
    
    // 动效添加新元素
    func animateNewCookies(columns: [[Cookie]], completion: () -> ()) {
        var longestDuration: NSTimeInterval = 0
        
        for array in columns {
            let startRow = array[0].row + 1 // 最上面位置，新元素是从上到下排列的
            for (idx, cookie) in array.enumerate() {
                let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
                sprite.position = pointForColumn(cookie.column, row: startRow) // 初始位置从最上面开始掉落
                cookiesLayer.addChild(sprite)
                cookie.sprite = sprite

                let delay = 0.1 + 0.2 * NSTimeInterval(array.count - idx - 1) // 反向延迟，最上面的动效最快
                let duration = NSTimeInterval(startRow - cookie.row) * 0.1
                
                longestDuration = max(longestDuration, duration + delay)

                let newPosition = pointForColumn(cookie.column, row: cookie.row)
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.alpha = 0
                sprite.runAction(SKAction.sequence([
                    SKAction.waitForDuration(delay),
                    SKAction.group([
                        SKAction.fadeInWithDuration(0.05),
                        moveAction,
                        addCookieSound])
                ]))
            }
        }

        // 等待动效完成后返回
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }
    
    // 动效每个匹配的分值
    func animateScoreForChain(line: Line) {
        let firstCookie = line.cookies.first!
        let lastCookie = line.cookies.last!
        
        if let firstSprite = firstCookie.sprite {
            if let lastSprite = lastCookie.sprite {
                // 显示的位置位于中间
                let centerPosition = CGPointMake(
                    (firstSprite.position.x + lastSprite.position.x) / 2,
                    (firstSprite.position.y + lastSprite.position.y) / 2 - 8
                )
                
                let scoreLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
                scoreLabel.fontSize = 16
                scoreLabel.text = String(format: "%lu", line.points);
                scoreLabel.position = centerPosition;
                scoreLabel.zPosition = 300;
                cookiesLayer.addChild(scoreLabel)
                
                let moveAction = SKAction.moveBy(CGVectorMake(0, 3), duration: 0.7)
                moveAction.timingMode = .EaseOut;
                scoreLabel.runAction(SKAction.sequence([
                    moveAction,
                    SKAction.removeFromParent()
                ]))
            }
        }
    }
    
    // 动效游戏结束
    func animateGameOver(){
        let action = SKAction.moveBy(CGVectorMake(0, -self.size.height), duration: 0.3)
        action.timingMode = .EaseIn
        gameLayer.runAction(action)
    }
    
    // 动效游戏开始
    func animateBeginGame(){
        gameLayer.hidden = false
        
        gameLayer.position = CGPointMake(0, self.size.height)
        let action = SKAction.moveBy(CGVectorMake(0, -self.size.height), duration: 0.3)
        action.timingMode = .EaseOut
        gameLayer.runAction(action)
    }
    
    // MARK: - 工具
    
    // 坐标定位
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    // 坐标转换
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(level.NumColumns)*TileWidth &&
            point.y >= 0 && point.y < CGFloat(level.NumRows)*TileHeight {
            return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
}
