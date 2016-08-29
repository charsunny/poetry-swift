//
//  User.swift
//  poetry
//
//  Created by sunsing on 8/28/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class Login: Mappable {
    
    var token:String?
    
    var user:User?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        token <- map["token"]
        user <- map["user"]
    }
    
    static func LoginWithSNS(nick:String, gender:Int, avatar:String, userId:String, snsType:Int,  finish:(Login?, BackendError?)->Void) {
        let param:[String:AnyObject] = ["userid":userId, "nick":nick, "avatar":avatar, "type":snsType, "gender":gender]
        Alamofire.request(Router.Base(.POST, "login", param)).responseObject { (res :Response<Login, BackendError>) in
            res.result.success({ (value) in
                User.LoginUser = value.user
                User.Token = value.token
                NSNotificationCenter.defaultCenter().postNotificationName("LoginSuccess", object: nil)
                if value.user?.rongToken.characters.count > 0 {
                    RCIM.sharedRCIM().connectWithToken(value.user?.rongToken ?? "",
                        success: { (userId) -> Void in
                            print("登陆成功。当前登录的用户ID：\(userId)")
                        }, error: { (status) -> Void in
                            print("登陆的错误码为:\(status.rawValue)")
                        }, tokenIncorrect: {
                            print("token错误")
                    })
                }
                finish(value, nil)
            }).failure({ (error) in
                finish(nil, error)
            })
        }
    }
}

public class User: Mappable {
    
    static var LoginUser : User?
    
    static var Token : String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("token") as? String
        }
        set {
            if newValue == nil {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("token")
            } else {
                NSUserDefaults.standardUserDefaults().setObject(newValue!, forKey: "token")
            }
        }
    }
    
    static func GetUserInfo(finish:(User?, BackendError?)->Void) {
        Alamofire.request(Router.User(.GET, "info", [:])).responseObject { (res :Response<User, BackendError>) in
            res.result.success({ (value) in
                User.LoginUser = value
                NSNotificationCenter.defaultCenter().postNotificationName("LoginSuccess", object: nil)
                if value.rongToken.characters.count > 0 {
                    RCIM.sharedRCIM().connectWithToken(value.rongToken ?? "",
                        success: { (userId) -> Void in
                            print("登陆成功。当前登录的用户ID：\(userId)")
                        }, error: { (status) -> Void in
                            print("登陆的错误码为:\(status.rawValue)")
                        }, tokenIncorrect: {
                            print("token错误")
                    })
                }
                finish(value, nil)
            }).failure({ (error) in
                finish(nil, error)
            })
        }
    }
    
    var id   : Int = 0
    var nick : String = ""
    var avatar	: String = ""
    var gender  : Int = 0
    var likeCount : Int = 0		//喜欢的诗词数量
    var columnCount : Int = 0	// 专辑数量
    var followCount : Int = 0	// 关注的数量
    var followeeCount : Int = 0	// 被关注的数量
    var rongUser : String = ""// rongyun用户名
    var rongToken : String = ""// rong token
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id <- map["Id"]
        nick <- map["Nick"]
        avatar <- map["Avatar"]
        gender <- map["Gender"]
        likeCount <- map["LikeCount"]
        columnCount <- map["ColumnCount"]
        followCount <- map["FollowCount"]
        followeeCount <- map["FolloweeCount"]
        rongUser <- map["RongUser"]
        rongToken <- map["RongToken"]
    }
}
