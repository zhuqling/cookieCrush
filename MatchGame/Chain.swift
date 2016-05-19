//
//  Line.swift
//  MatchGame
//
//  Created by Yifan Xiao on 5/18/15.
//  Copyright (c) 2015 Yifan Xiao. All rights reserved.
//

class Line: Hashable, CustomStringConvertible {
    var cookies = [Cookie]()
    
    var points = 0
    
    enum LineType: CustomStringConvertible {
        case Horizontal
        case Vertical
        
        var description: String {
            switch self {
            case .Horizontal: return "Horizontal"
            case .Vertical: return "Vertical"
            }
        }
    }
    
    var lineType: LineType
    
    init(lineType: LineType) {
        self.lineType = lineType
    }
    
    func addCookie(cookie: Cookie) {
        cookies.append(cookie)
    }
    
    func firstCookie() -> Cookie {
        return cookies[0]
    }
    
    func lastCookie() -> Cookie {
        return cookies[cookies.count - 1]
    }
    
    var length: Int {
        return cookies.count
    }
    
    var description: String {
        return "type:\(lineType) cookies:\(cookies)"
    }
    
    var hashValue: Int {
        return cookies.reduce(0, combine:{ $0.hashValue ^ $1.hashValue })
    }
}

func ==(lhs: Line, rhs: Line) -> Bool {
    return lhs.cookies == rhs.cookies
}
