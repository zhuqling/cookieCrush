//
//  Extensions.swift
//  MatchGame
//
//  Created by Yifan Xiao on 5/14/15.
//  Copyright (c) 2015 Yifan Xiao. All rights reserved.
//

import Foundation

extension Dictionary {
    static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
            
            var error: NSError?
            let data = NSData.init(contentsOfFile: path) // NSData(contentsOfFile: path, options: NSDataReadingOptions(), error: &error)
            if let data = data {
                
                let dictionary: AnyObject? = try! NSJSONSerialization.JSONObjectWithData(data,
                    options: NSJSONReadingOptions())
                if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                    return dictionary
                } else {
                    print("Level file '\(filename)' is not valid JSON: \(error!)")
                    return nil
                }
            } else {
                print("Could not load level file: \(filename), error: \(error!)")
                return nil
            }
        } else {
            print("Could not find level file: \(filename)")
            return nil
        }
    }
}
