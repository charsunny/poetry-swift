//
//  AppDelegate.swift
//  poetry
//
//  Created by 诺崇 on 16/5/10.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import JDStatusBarNotification
import SVProgressHUD

public let DocumentPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!

public let CachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!

public var LocalDBExist = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var audioPlayer: AudioPlayer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if FileManager.default.fileExists(atPath: DocumentPath + "/poem.db") {
            LocalDBExist = DataManager.manager.connect()
        }
        
        //UINavigationBar.appearance().tintColor = UIColor.flatRedColor()
        RCIM.shared().initWithAppKey("8w7jv4qb77vey")
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp("4225157019")
        
        SVProgressHUD.setMinimumDismissTimeInterval(3)
        if launchOptions == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
            window?.makeKeyAndVisible()
        } else {
            if let url = launchOptions?[UIApplicationLaunchOptionsKey.url] as? URL {
                _ = AppDelegate.handleOpenURL(url)
            }
            if let local = launchOptions?[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
                debugPrint(local)
            }
            if let userinfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String:AnyObject] {
                debugPrint(userinfo)
            }
        }
        do {
            audioPlayer = try AudioPlayer(fileName: "bg.mp3")
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 1
            if !User.BgMusicOff {
                audioPlayer?.play()
            }
        } catch {
            debugPrint("play failed")
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "BGMusicChangeNotif"), object: nil, queue: OperationQueue.main) { (_) in
            if User.BgMusicOff {
                self.audioPlayer?.stop()
            } else {
                self.audioPlayer?.play()
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS ®message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        var canHandle = AppDelegate.handleOpenURL(url)
        if canHandle {
            return true
        }
        canHandle = WeiboSDK.handleOpen(url, delegate: self)
        if canHandle {
            return true
        }
        canHandle = TencentOAuth.handleOpen(url)
        if canHandle {
            return true
        }
        return true
    }
    
    static func handleOpenURL(_ url:URL) -> Bool {
        if url.scheme == "poem" {
            if url.host == "poem" {
                if let pid = Int(url.lastPathComponent), pid > 0 {
                    if let tabeVC = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                        if let navVC = tabeVC.selectedViewController as? UINavigationController {
                            if let poemVC = UIStoryboard(name: "Recommend", bundle: nil).instantiateViewController(withIdentifier: "poemvc") as? PoemDetailViewController {
                                poemVC.poemId = pid
                                navVC.pushViewController(poemVC, animated: true)
                                return true
                            }
                        }
                    }
                }
            }
            if url.host == "poet" {
                if let pid = Int(url.lastPathComponent), pid > 0 {
                    if let tabeVC = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                        if let navVC = tabeVC.selectedViewController as? UINavigationController {
                            if let poetVC = UIStoryboard(name: "Recommend", bundle: nil).instantiateViewController(withIdentifier: "poetvc") as? AuthorViewController {
                                let poet = DataManager.manager.poetById(pid)
                                poetVC.poet = poet
                                navVC.pushViewController(poetVC, animated: true)
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }
}

extension AppDelegate : WeiboSDKDelegate {
    
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        
    }
    
    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        if let result = response as? WBAuthorizeResponse {
            if let userInfo = result.userInfo {
                var nick = ""
                var avatar = ""
                if let dict = userInfo["app"] as? NSDictionary {
                    nick = dict["name"] as? String ?? ""
                    avatar = dict["logo"] as? String ?? ""
                }
                Login.LoginWithSNS(nick, gender: 1, avatar: avatar, userId: userInfo["uid"] as? String ?? "", snsType: 1, finish: { (login, err) in
                    if err != nil {
                        JDStatusBarNotification.show(withStatus: "登录失败", dismissAfter:1, styleName:JDStatusBarStyleError)
                    }
                })
            } else {
                JDStatusBarNotification.show(withStatus: "拉取授权信息失败", dismissAfter:1, styleName:JDStatusBarStyleError)
            }
        }
    }
}

