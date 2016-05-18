//
//  AppDelegate.swift
//  MatchGame
//
//  Created by Yifan Xiao on 5/14/15.
//  Copyright (c) 2015 Yifan Xiao. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var splash:UIImageView?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: #selector(AppDelegate.removeSplashView), name: "tableViewdidLoad", object: nil)
        
        splash = UIImageView(frame: self.window!.bounds)
        splash!.backgroundColor = UIColor.whiteColor()
        
        let iconView = UIView(frame: CGRectMake(self.window!.bounds.size.width/2-100, self.window!.bounds.size.height/2-100, 200, 200))
        
        let imageView = UIImageView(image: UIImage(named: "cookie.png"))
        
        iconView.addSubview(imageView)
        splash!.addSubview(iconView)
        
        self.window!.rootViewController!.view.addSubview(splash!)
        
        return true
    }
    
    func removeSplashView(){
        
        UIView.animateWithDuration(0.1,
            animations: {self.splash!.alpha = 0.0},
            completion: {
                (value: Bool) in
                
                self.splash?.removeFromSuperview()
        })
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

