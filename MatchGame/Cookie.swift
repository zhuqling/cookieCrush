//
//  Cookie.swift
//  MatchGame
//
//  Created by Yifan Xiao on 5/14/15.
//  Copyright (c) 2015 Yifan Xiao. All rights reserved.
//

import SpriteKit

class Cookie :Printable, Hashable {
    var column: Int
    var row: Int
    let cookieType: CookieType
    var sprite: SKSpriteNode?
    //for the grid at (column, row), the sprite may not there
    
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
}

enum CookieType: Int, Printable {
    case Unknown = 0, Croissant, Cupcake, Danish, Donut, Macaroon, SugarCookie
    
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
    
    static func random() -> CookieType {
        return CookieType(rawValue: Int(arc4random_uniform(6)) + 1)!
        //the returned index is 1----6
    }
    
    var description: String {
        return spriteName
    }
}

func ==(lhs: Cookie, rhs: Cookie) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}