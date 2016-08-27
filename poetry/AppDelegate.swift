//
//  AppDelegate.swift
//  poetry
//
//  Created by 诺崇 on 16/5/10.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import SQLite

let ServerURL = "http://ansinlee.com/"

public enum PoemFont : String {
    case 汉仪全唐诗简体 = "HYQuanTangShiJ"
    case 汉仪全唐诗繁体 = "HYQuanTangShiF"
    case 方正宋刻本秀楷简体 = "FZSongKeBenXiuKaiS-R-GB"
    case 方正宋刻本秀楷繁体 = "FZSongKeBenXiuKaiT-R-GB"
    case 方正北魏楷书简体 = "FZBeiWeiKaiShu-S19S"
    case 方正北魏楷书繁体 = "FZBeiWeiKaiShu-Z15T"
}

public var UserFont = PoemFont.汉仪全唐诗简体.rawValue

public let DocumentPath:String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!

public var NeedDownloadDB = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        if let font = NSUserDefaults.standardUserDefaults().objectForKey("font") as? String {
            UserFont = font
        }
        if NSFileManager.defaultManager().fileExistsAtPath(DocumentPath.stringByAppendingString("/poem.db")) {
            DataManager.manager.connect()
        } else {
            NeedDownloadDB = true
        }
        //UINavigationBar.appearance().tintColor = UIColor.flatRedColor()
        RCIM.sharedRCIM().initWithAppKey("8w7jv4qb77vey")
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp("4225157019")
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS ®message) or when the user quits the application and it begins the transition to the background state.
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

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        var canHandle = WeiboSDK.handleOpenURL(url, delegate: self)
        if canHandle {
            return true
        }
        canHandle = TencentOAuth.HandleOpenURL(url)
        if canHandle {
            return true
        }
        return true
    }
}

extension AppDelegate : WeiboSDKDelegate {
    
    func didReceiveWeiboRequest(request: WBBaseRequest!) {
        
    }
    
    func didReceiveWeiboResponse(response: WBBaseResponse!) {
        if let result = response as? WBAuthorizeResponse {
            //debugPrint(result.userInfo)
        }
    }
}

