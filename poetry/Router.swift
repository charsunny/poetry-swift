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

enum Router : URLRequestConvertible {
    
    #if !DEBUG
    static let baseURLString = "http://api.charsunny.com"
    //static let baseURLString = "http://121.41.112.242:8080"
    #else
    static let baseURLString = "http://192.168.3.17:8080"
    #endif
    
    public func asURLRequest() throws -> URLRequest {
        let URL = Foundation.URL(string: Router.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(url: URL.appendingPathComponent(req.path))
        mutableURLRequest.httpMethod = req.method.rawValue
        mutableURLRequest.timeoutInterval = 15
        let parameters = preDealWithParam(req.param)
        let md5:String? = ""//BMHTTPRequest.sign(parm, path: req.path)
        if md5 != nil {
            mutableURLRequest.setValue(md5, forHTTPHeaderField: "md5")
        }
        let urlRequest = try URLEncoding.default.encode(mutableURLRequest as URLRequest, with: parameters)
        return urlRequest
    }
    
   
    static let version = "v1"
    static let pageSize = 30
    
    case user(HTTPMethod , String, [String:Any])
    case poem(HTTPMethod , String, [String:Any])
    case poet(HTTPMethod , String, [String:Any])
    case recommend(HTTPMethod, String, [String:Any])
    case search(HTTPMethod, String, [String:Any])
    case feed(HTTPMethod, String, [String:Any])
    case base(HTTPMethod, String, [String:Any])
    case message(HTTPMethod, String, [String:Any])
    case request(HTTPMethod, String, [String:Any])    // 直接请求不需要author的请求
    
    var req:(method:HTTPMethod, path:String, param: [String:Any]) {
        switch self {
        case let .user(method, path, param):
            return (method, "/\(Router.version)/user/\(path)", param)
        case let .poem(method, path, param):
            return (method, "/\(Router.version)/poem/\(path)", param)
        case let .poet(method, path, param):
            return (method, "/\(Router.version)/poet/\(path)", param)
        case let .recommend(method, path, param):
            return (method, "/\(Router.version)/rec/\(path)", param)
        case let .search(method, path, param):
            return (method, "/\(Router.version)/search/\(path)", param)
        case let .feed(method, path, param):
            return (method, "/\(Router.version)/feed/\(path)", param)
        case let .base(method, path, param):
            return (method, "/\(Router.version)/common/\(path)", param)
        case let .message(method, path, param):
            return (method, "/\(Router.version)/msg/\(path)", param)
        case let .request(method, path, param):
            return (method, "/\(Router.version)/\(path)", param)
        }
    }
    
    func preDealWithParam(_ param: [String: Any]) -> [String: String] {
        
        var newParam:[String:String] = [:]
        // TODO: 现在只能处理一层参数的请求，不支持多级参数，否则转string会失败
        param.forEach({
            newParam[$0.0] = String(describing: $0.1) 
        })
        newParam["t"] = String(Int(Date().timeIntervalSince1970))
        if let token = PoemUser.Token , needAuth {
            newParam["access_token"] = token
        }
        return newParam
    }
    
    var needAuth:Bool {
        switch self {
        case .request, .base:
            return false
        default:
            return true
        }
    }
}
