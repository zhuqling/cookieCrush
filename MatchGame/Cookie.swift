/*
 * 元素
 */

import SpriteKit

// The objects that you put into the set must conform to the Hashable protocol
class Cookie : CustomStringConvertible, Hashable {
    var column: Int
    var row: Int
    let cookieType: CookieType
    var sprite: SKSpriteNode? // for the grid at (column, row), the sprite may not there
    
    init(column: Int, row: Int, cookieType: CookieType) {
        self.column = column
        self.row = row
        self.cookieType = cookieType
    }
    
    var description: String {
        return "type:\(cookieType) square:(\(column),\(row))"
    }
    
    var hashValue: Int {
        return row*10 + column
    }
    //required for hashable protocol
}


//pragma mark - supply the == comparison operator for comparing two objects of the same type
func ==(lhs: Cookie, rhs: Cookie) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}

enum CookieType: Int, CustomStringConvertible {
    case Unknown = 0, Croissant, Cupcake, Danish, Donut, Macaroon, SugarCookie
    case Length
    
    // 总数
    static var number: UInt32 {
        return UInt32(Length.rawValue)-1
    }
    
    var spriteName: String {
        let spriteNames = [
            "Croissant",
            "Cupcake",
            "Danish",
            "Donut",
            "Macaroon",
            "SugarCookie"]
        
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    // 随机
    static func random() -> CookieType {
        return CookieType(rawValue: Int(arc4random_uniform(number)) + 1)!
        //the returned index is 1----6
    }
    
    var description: String {
        return spriteName
    }
}
