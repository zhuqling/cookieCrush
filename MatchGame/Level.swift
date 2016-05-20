/*
 * 关卡
 */

import Foundation

class Level {
    var NumColumns = 9 // 列数
    var NumRows = 9 // 行数
    
    var targetScore = 0 // 目标分
    var maximumMoves = 0 // 步数
    var comboMultiplier = 0 // 连击
    
    private var cookies: Array2D<Cookie>!
    private var tiles: Array2D<Tile>!
    
    private var possibleSwaps = Set<Swap>()
    
    // MARK: - 关卡加载
    
    // 从关卡文件加载
    init(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            if let tilesArray: AnyObject = dictionary["tiles"]
            {
                targetScore = dictionary["targetScore"] as! Int
                maximumMoves = dictionary["moves"] as! Int
                
                if let col = dictionary["col"] as! Int? {
                    NumColumns = col
                }
                
                if let row = dictionary["row"] as! Int? {
                    NumRows = row
                }
                
                cookies = Array2D<Cookie>(columns: NumColumns, rows: NumRows)
                tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
                
                for (rowIdx, rowArray) in (tilesArray as! [[Int]]).enumerate() {
                    let row = NumRows - rowIdx - 1 // 关卡的上下方向与存储结构是颠倒的，因为坐标系的问题
                    for (column, value) in rowArray.enumerate() {
                        if value == 1 { // 被占位代表可用位置
                            tiles[column, row] = Tile()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Game Setup
    
    // 随机
    func shuffle() -> Set<Cookie> {
        var set: Set<Cookie>
        repeat {
            set = createInitialCookies()
            detectPossibleSwaps()
//            print("possible swaps: \(possibleSwaps)")
        } while possibleSwaps.count == 0
        
        return set
    }
    
    // 创建初始元素
    private func createInitialCookies() -> Set<Cookie> {
        var set = Set<Cookie>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if tiles[column, row] != nil
                {
                    // 避免初始元素时已经匹配
                    var cookieType: CookieType!
                    repeat {
                        cookieType = CookieType.random()
                    } while (
                        (column >= 2 &&
                            cookies[column - 1, row] != nil && cookies[column - 1, row]!.cookieType == cookieType &&
                            cookies[column - 2, row] != nil && cookies[column - 2, row]!.cookieType == cookieType) ||
                        (row >= 2 &&
                            cookies[column, row - 1] != nil && cookies[column, row - 1]!.cookieType == cookieType &&
                            cookies[column, row - 2] != nil && cookies[column, row - 2]!.cookieType == cookieType)
                    )
                    
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                    
                    set.insert(cookie)
                }
            }
        }
        return set
    }
    
    // 复位连击
    func resetComboMultiplier(){
        comboMultiplier = 1
    }
    
    // MARK: - 检测交换
    
    // 检测交换是否成立，是否满足横向/纵向的匹配
    func detectPossibleSwaps() {
        var set = Set<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let cookie = cookies[column, row] {
                    if column < NumColumns - 1 { // 总是尝试与右边一个进行交换
                        if let other = cookies[column + 1, row] {
                            // 尝试交换
                            cookies[column, row] = other
                            cookies[column + 1, row] = cookie
                            
                            // 检测是否有匹配
                            if hasLineAtColumn(column + 1, row: row) ||
                               hasLineAtColumn(column, row: row) {
                                set.insert(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                            // 恢复原位
                            cookies[column, row] = cookie
                            cookies[column + 1, row] = other
                        }
                    }
                    
                    if row < NumRows - 1 { // 总是尝试与上边一个进行交换
                        if let other = cookies[column, row + 1] {
                            cookies[column, row] = other
                            cookies[column, row + 1] = cookie
                            
                            if hasLineAtColumn(column, row: row + 1) ||
                               hasLineAtColumn(column, row: row) {
                                set.insert(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                            cookies[column, row] = cookie
                            cookies[column, row + 1] = other
                        }
                    }
                }
            }
        }
        
        possibleSwaps = set
    }
    
    // 检测是否有匹配
    private func hasLineAtColumn(column: Int, row: Int) -> Bool {
        let cookieType = cookies[column, row]!.cookieType
        
        var horzLength = 1
        for i in (column - 1).stride(through: 0, by: -1) {
            if cookies[i, row]?.cookieType != cookieType {
                break
            }
            
            horzLength += 1
        }
        
        for i in (column + 1)..<NumColumns {
            if cookies[i, row]?.cookieType != cookieType {
                break
            }
            
            horzLength += 1
        }
        
        if horzLength >= 3 { return true }
        
        var vertLength = 1
        for i in (row - 1).stride(through: 0, by: -1) {
            if cookies[column, i]?.cookieType != cookieType {
                break
            }
            
            vertLength += 1
        }
        
        for i in (row + 1)..<NumRows {
            if cookies[column, i]?.cookieType != cookieType {
                break
            }
            
            vertLength += 1
        }
        
        return vertLength >= 3
    }
    
    // MARK: -  交换
    
    // 执行交换
    func performSwap(swap: Swap) {
        let columnA = swap.cookieA.column
        let rowA = swap.cookieA.row
        
        let columnB = swap.cookieB.column
        let rowB = swap.cookieB.row
        
        cookies[columnA, rowA] = swap.cookieB
        swap.cookieB.column = columnA
        swap.cookieB.row = rowA
        
        cookies[columnB, rowB] = swap.cookieA
        swap.cookieA.column = columnB
        swap.cookieA.row = rowB
    }
    
    // MARK: - 检测匹配
    
    // 检测横向匹配
    private func detectHorizontalMatches() -> Set<Line> {
        var set = Set<Line>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns - 2 {
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType

                    if cookies[column + 1, row]?.cookieType == matchType &&
                       cookies[column + 2, row]?.cookieType == matchType {
                        let line = Line(lineType: .Horizontal)

                        var newColumn = column
                        repeat {
                            line.addCookie(cookies[newColumn, row]!)
                            newColumn += 1
                        } while newColumn < NumColumns && cookies[newColumn, row]?.cookieType == matchType
                        
                        set.insert(line)
                        continue
                    }
                }
            }
        }
        return set
    }
    
    // 检测纵向匹配
    private func detectVerticalMatches() -> Set<Line> {
        var set = Set<Line>()
        
        for column in 0..<NumColumns {
            for row in 0..<NumRows - 2 {
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType
                    
                    if cookies[column, row + 1]?.cookieType == matchType &&
                       cookies[column, row + 2]?.cookieType == matchType {
                        let line = Line(lineType: .Vertical)
                        
                        var newRow = row
                        repeat {
                            line.addCookie(cookies[column, newRow]!)
                            newRow += 1
                        } while newRow < NumRows && cookies[column, newRow]?.cookieType == matchType
                        
                        set.insert(line)
                        continue
                    }
                }
            }
        }
        return set
    }
    
    // 移除匹配
    func removeMatches() -> Set<Line> {
        let horizontalLines = detectHorizontalMatches()
        let verticalLines = detectVerticalMatches()
        
        // 先清除数据
        removeCookies(horizontalLines)
        removeCookies(verticalLines)
        
        // 计分
        calculateScores(horizontalLines)
        calculateScores(verticalLines)
        
        return horizontalLines.union(verticalLines)
    }
    
    // 移除元素（数据模型）
    private func removeCookies(lines: Set<Line>) {
        for line in lines {
            for cookie in line.cookies {
                cookies[cookie.column, cookie.row] = nil
            }
        }
    }
    
    // 计分
    func calculateScores(chains: Set<Line>) {
        // 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
        for chain in chains {
            chain.points = 60 * (chain.length - 2) * comboMultiplier
            comboMultiplier += 1
        }
    }
    
    // MARK: - 检测空洞
    
    // 填充空洞（数据模型），用于移除匹配后自动将上面的元素移下，并填充新的元素
    func fillHoles() -> [[Cookie]] {
        var columns = [[Cookie]]()

        for column in 0..<NumColumns {
            var array = [Cookie]()
            for row in 0..<NumRows {
                if tiles[column, row] != nil && cookies[column, row] == nil { // 地图有占位并且元素结构未占位
                    for lookup in (row + 1)..<NumRows {
                        if let cookie = cookies[column, lookup] { // 交换上一行到空缺的位置
                            cookies[column, lookup] = nil
                            cookies[column, row] = cookie
                            cookie.row = row

                            array.append(cookie)
                            break
                        }
                    }
                }
            }
            
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    // 从上面添加新元素
    func topUpCookies() -> [[Cookie]] {
        var columns = [[Cookie]]()
        var cookieType: CookieType = .Unknown // 最后一个元素类型，用于避免生成重复元素
        
        for column in 0..<NumColumns {
            var array = [Cookie]()
            
            for row in (NumRows-1).stride(through: 0, by: -1) { // 从上往下
                if cookies[column, row] != nil { // 当遇到不为空的位置时说明全部都满了
                    break
                }

                if tiles[column, row] != nil {
                    var newCookieType: CookieType
                    
                    repeat {
                        newCookieType = CookieType.random()
                    } while newCookieType == cookieType
                    
                    cookieType = newCookieType

                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                    array.append(cookie)
                }
            }
            
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    // MARK: - 查询工具
    
    // 按坐标访问贴砖
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    // 按坐标访问元素
    func cookieAtColumn(column: Int, row: Int) -> Cookie? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        
        return cookies[column, row]
    }
    
    // 检测交换是否成立
    func isPossibleSwap(swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }
}

