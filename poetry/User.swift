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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class Login: Mappable {
    
    var token:String?
    
    var user:User?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        token <- map["token"]
        user <- map["user"]
    }
    
    static func LoginWithSNS(_ nick:String, gender:Int, avatar:String, userId:String, snsType:Int,  finish:@escaping (Login?, Error?)->Void) {
        let param:[String:AnyObject] = ["userid":userId as AnyObject, "nick":nick as AnyObject, "avatar":avatar as AnyObject, "type":snsType as AnyObject, "gender":gender as AnyObject]
        Alamofire.request(Router.base(.post, "login", param)).responseObject { (res :DataResponse<Login>) in
            switch res.result {
            case let .success(value):
                User.LoginUser = value.user
                User.Token = value.token
                NotificationCenter.default.post(name: Notification.Name(rawValue: "LoginSuccess"), object: nil)
                if value.user?.rongToken.characters.count > 0 {
                    RCIM.shared().connect(withToken: value.user?.rongToken ?? "",
                                          success: { (userId) -> Void in
                                            print("登陆成功。当前登录的用户ID：\(userId)")
                        }, error: { (status) -> Void in
                            print("登陆的错误码为:\(status.rawValue)")
                        }, tokenIncorrect: {
                            print("token错误")
                    })
                }
                finish(value, nil)
            case let .failure(error):
                 finish(nil, error)
            }
        }
    }
}

open class User: Mappable {
    
    static var LoginUser : User?
    
    static var Font : String {
        get {
            if let font = UserDefaults.standard.object(forKey: "font") as? String {
                return font
            } else {
                return "HYQuanTangShiJ"
            }
        }
        set {
            if newValue == "" {
                 UserDefaults.standard.set("system", forKey: "font")
            } else {
                UserDefaults.standard.set(newValue, forKey: "font")
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "UserFontChangeNotif"), object: nil)
        }
    }
    
    static var BgMusicOff : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "BgMusicOff")
        }
        set {
            if newValue == true {
                UserDefaults.standard.set(true, forKey: "BgMusicOff")
            } else {
                UserDefaults.standard.set(false, forKey: "BgMusicOff")
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "BGMusicChangeNotif"), object: nil)
        }
    }
    
    static var Token : String? {
        get {
            return UserDefaults.standard.object(forKey: "token") as? String
        }
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "token")
            } else {
                UserDefaults.standard.set(newValue!, forKey: "token")
            }
        }
    }
    
    static func GetUserInfo(_ id : Int = 0, _ finish:@escaping (User?, Error?)->Void) {
        Alamofire.request(Router.user(.get, "info", ["id":id])).responseObject { (res :DataResponse<User>) in
            switch res.result {
            case let .success(value) :
                User.LoginUser = value
                NotificationCenter.default.post(name: Notification.Name(rawValue: "LoginSuccess"), object: nil)
                if value.rongToken.characters.count > 0 {
                    RCIM.shared().connect(withToken: value.rongToken ,
                                          success: { (userId) -> Void in
                                            print("登陆成功。当前登录的用户ID：\(userId)")
                        }, error: { (status) -> Void in
                            print("登陆的错误码为:\(status.rawValue)")
                        }, tokenIncorrect: {
                            print("token错误")
                    })
                }
                finish(value, nil)
            case let .failure(error):
                finish(nil, error)
            }
        }
    }
    
    static func UploadPic(_ image:UIImage, finish:@escaping (Bool, String?)->Void) {
        if let imagedata =
            
            UIImageJPEGRepresentation(image, 0.5) {

            let path = "\(CachePath)/\(image.hashValue).jpg"
            try? imagedata.write(to: URL(fileURLWithPath: path), options: [.atomic])
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(URL(fileURLWithPath: path), withName: "image")
                },
                to: "\(Router.baseURLString)/v1/common/pic",
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            if let dict = response.result.value as? NSDictionary {
                                if dict["errcode"] as? Int == 0 {
                                    if let url = dict["data"] as? String {
                                        debugPrint(url)
                                        finish(true, url)
                                        return
                                    }
                                }
                            }
                            finish(false, nil)
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                        finish(false, nil)
                    }
                }
            )
        }
    }
    
    func addComment(type:Int, id:Int, cid:Int, content:String, finish:@escaping (Comment?, Error?)->Void) {
        Alamofire.request(Router.user(.post, "addcomment", ["type":type, "id":id, "cid":cid, "content":content])).responseObject { (res :DataResponse<Comment>) in
            switch res.result {
            case let .success(value) :
                finish(value, nil)
            case let .failure(error):
                finish(nil, error)
            }
        }
    }
    
    func likeComment(cid:Int, finish:@escaping (Comment?, Error?)->Void) {
        Alamofire.request(Router.user(.post, "likecomment", ["cid":cid])).responseObject { (res :DataResponse<Comment>) in
            switch res.result {
            case let .success(value) :
                finish(value, nil)
            case let .failure(error):
                finish(nil, error)
            }
        }
    }
    
    func unlikeComment(cid:Int, finish:@escaping (Comment?, Error?)->Void) {
        Alamofire.request(Router.user(.post, "unlikecomment", ["cid":cid])).responseObject { (res :DataResponse<Comment>) in
            switch res.result {
            case let .success(value) :
                finish(value, nil)
            case let .failure(error):
                finish(nil, error)
            }
        }
    }
    
    func likeFeed (cid:Int, finish:@escaping (Feed?, Error?)->Void) {
        Alamofire.request(Router.user(.post, "likefeed", ["cid":cid])).responseObject { (res :DataResponse<Feed>) in
            switch res.result {
            case let .success(value) :
                finish(value, nil)
            case let .failure(error):
                finish(nil, error)
            }
        }
    }
    
    func unlikeFeed (cid:Int, finish:@escaping (Feed?, Error?)->Void) {
        Alamofire.request(Router.user(.post, "unlikefeed", ["cid":cid])).responseObject { (res :DataResponse<Feed>) in
            switch res.result {
            case let .success(value) :
                finish(value, nil)
            case let .failure(error):
                finish(nil, error)
            }
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
    
    required public init?(map: Map) {
        
    }
    
    open func mapping(map: Map) {
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
        if nick.characters.count == 0 {
            nick = "诗词用户"
        }
    }
}
