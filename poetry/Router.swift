//
//  Route.swift
//  S4SUserClient
//
//  Created by zikong on 16/6/15.
//  Copyright © 2016年 zikong. All rights reserved.
//

import UIKit
import Alamofire

typealias PoemUser = User
typealias RequestMethod = Alamofire.Method

enum Router : URLRequestConvertible {
    
#if DEBUG
    //static let baseURLString = "http://api.classicpoem.cn"
    static let baseURLString = "http://121.41.112.242:8080"
#else
    static let baseURLString = "http://192.168.31.206:8080"
#endif
   
    static let version = "v1"
    static let pageSize = 30
    
    case User(RequestMethod , String, [String:AnyObject])
    case Poem(RequestMethod , String, [String:AnyObject])
    case Poet(RequestMethod , String, [String:AnyObject])
    case Recommend(RequestMethod, String, [String:AnyObject])
    case Search(RequestMethod, String, [String:AnyObject])
    case Feed(RequestMethod, String, [String:AnyObject])
    case Base(RequestMethod, String, [String:AnyObject])
    case Message(RequestMethod, String, [String:AnyObject])
    case Request(RequestMethod, String, [String:AnyObject])    // 直接请求不需要author的请求
    
    var req:(method:RequestMethod, path:String, param: [String:AnyObject]) {
        switch self {
        case let .User(method, path, param):
            return (method, "/\(Router.version)/user/\(path)", param)
        case let .Poem(method, path, param):
            return (method, "/\(Router.version)/poem/\(path)", param)
        case let .Poet(method, path, param):
            return (method, "/\(Router.version)/poet/\(path)", param)
        case let .Recommend(method, path, param):
            return (method, "/\(Router.version)/rec/\(path)", param)
        case let .Search(method, path, param):
            return (method, "/\(Router.version)/search/\(path)", param)
        case let .Feed(method, path, param):
            return (method, "/\(Router.version)/feed/\(path)", param)
        case let .Base(method, path, param):
            return (method, "/\(Router.version)/common/\(path)", param)
        case let .Message(method, path, param):
            return (method, "/\(Router.version)/msg/\(path)", param)
        case let .Request(method, path, param):
            return (method, "/\(Router.version)/\(path)", param)
        }
    }
    
    func preDealWithParam(param: [String: AnyObject]) -> [String: String] {
        
        var newParam:[String:String] = [:]
        // TODO: 现在只能处理一层参数的请求，不支持多级参数，否则转string会失败
        param.forEach({
            newParam[$0.0] = String($0.1) ?? ""
        })
        newParam["t"] = String(Int(NSDate().timeIntervalSince1970))
        if let token = PoemUser.Token where needAuth {
            newParam["access_token"] = token
        }
        return newParam
    }
    
    var needAuth:Bool {
        switch self {
        case .Request, .Base:
            return false
        default:
            return true
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: Router.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(req.path))
        mutableURLRequest.HTTPMethod = req.method.rawValue
        mutableURLRequest.timeoutInterval = 15
        let parm = preDealWithParam(req.param)
        let md5:String? = ""//BMHTTPRequest.sign(parm, path: req.path)
        if md5 != nil {
            mutableURLRequest.setValue(md5, forHTTPHeaderField: "md5")
        }
        let encodedURLRequest = ParameterEncoding.URL.encode(mutableURLRequest, parameters: parm).0
        return encodedURLRequest
    }
    
}
