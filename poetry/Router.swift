//
//  Route.swift
//  S4SUserClient
//
//  Created by zikong on 16/6/15.
//  Copyright © 2016年 zikong. All rights reserved.
//

import UIKit
import Alamofire

enum Router : URLRequestConvertible {
    
#if !DEBUG
    static let baseURLString = "https://shop.api.mys4s.cn"
#else
    static let baseURLString = "http://192.168.3.5:8082"
#endif
   
    static let version = "v2"
    static let pageSize = 30
    
    case User(String, [String:AnyObject])
    case Order(String, [String:AnyObject])
    case Shop(String, [String:AnyObject])
    case Activity(String, [String:AnyObject])
    case Car(String, [String:AnyObject])
    case Bill(String, [String:AnyObject])
    case Pic(String, UIImage)
    case Request(String, [String:AnyObject])    // 直接请求不需要author的请求
    
    var req:(path:String, param: [String:AnyObject]) {
        switch self {
        case let .User(path, param):
            return ("/\(Router.version)/user/\(path)", param)
        case let .Order(path, param):
            return ("/\(Router.version)/order/\(path)", param)
        case let .Shop(path, param):
            return ("/\(Router.version)/shop/\(path)", param)
        case let .Activity(path, param):
            return ("/\(Router.version)/activity/\(path)", param)
        case let .Bill(path, param):
            return ("/\(Router.version)/bill/\(path)", param)
        case let .Car(path, param):
            return ("/\(Router.version)/car/\(path)", param)
        case let .Pic(path, param):
            return ("/\(Router.version)/pic/\(path)", ["image":param])
        case let .Request(path, param):
            return ("/\(Router.version)/\(path)", param)
        }
    }
    
    func preDealWithParam(param: [String: AnyObject]) -> [String: String] {
        
        var newParam:[String:String] = [:]
        // TODO: 现在只能处理一层参数的请求，不支持多级参数，否则转string会失败
        param.forEach({
            newParam[$0.0] = String($0.1) ?? ""
        })
        newParam["t"] = String(Int(NSDate().timeIntervalSince1970))
//        if let token = DataManager.accessToken where needAuth {
//            newParam["access_token"] = token
//        }
        return newParam
    }
    
    var needAuth:Bool {
        switch self {
        case .Request:
            return false
        default:
            return true
        }
    }
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: Router.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(req.path))
        mutableURLRequest.HTTPMethod = Method.POST.rawValue
        mutableURLRequest.timeoutInterval = 15
        let parm = preDealWithParam(req.param)
        let md5:String? = ""//BMHTTPRequest.sign(parm, path: req.path)
        if md5 != nil {
            mutableURLRequest.setValue(md5, forHTTPHeaderField: "md5")
        }
        do {
            let options = NSJSONWritingOptions()
            let data = try NSJSONSerialization.dataWithJSONObject(parm, options: options)
    
            if mutableURLRequest.valueForHTTPHeaderField("Content-Type") == nil {
                mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            mutableURLRequest.HTTPBody = data
        } catch {
            debugPrint("\(error)")
        }
        return mutableURLRequest
    }
    
}
