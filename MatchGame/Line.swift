/*
 * 用于判断匹配，横向/纵向
 */

class Line: Hashable, CustomStringConvertible {
    var cookies = [Cookie]()
    
    var points = 0 // 分数
    
    enum LineType: CustomStringConvertible {
        case Horizontal // 横向匹配
        case Vertical // 纵向匹配
        
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
