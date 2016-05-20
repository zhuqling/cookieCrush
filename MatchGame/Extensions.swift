/*
 * 扩展类
 */

import Foundation

extension Dictionary {
    static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
            
            let data = NSData.init(contentsOfFile: path)
            if let data = data {
                let dictionary: AnyObject? = try! NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions())
                if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                    return dictionary
                } else {
                    print("Level file '\(filename)' is not valid JSON")
                    return nil
                }
            } else {
                print("Could not load level file: \(filename)")
                return nil
            }
        } else {
            print("Could not find level file: \(filename)")
            return nil
        }
    }
}
