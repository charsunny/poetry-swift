//
//  Request.swift
//  S4SShopClient
//
//  Created by 诺崇 on 16/6/15.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

extension Result {
    func success(@noescape success: (value: Value) -> Void) -> Result<Value, Error> {
        switch self {
        case let .Success(value):
            success(value: value)
        default:
            break
        }
        return self
    }
    
    func failure(@noescape failure:(error: Error) -> Void) -> Result<Value, Error> {
        switch self {
        case let .Failure(error):
            failure(error:  error)
        default:
            break
        }
        return self
    }
}

extension Request {
    /**
     请求参数一个对象
     */
    
    func responseObject<T: Mappable>(queue queue: dispatch_queue_t? = nil, keyPath: String? = nil, mapToObject object: T? = nil, completionHandler: Response<T, BackendError> -> Void) -> Self {
        return response(queue: queue, responseSerializer: Request.S4SMapperSerializer(keyPath, mapToObject: object), completionHandler: completionHandler)
    }
    
    /**
     请求一个数组对象
     */
    func responseArray<T: Mappable>(queue queue: dispatch_queue_t? = nil, keyPath: String? = nil, completionHandler: Response<[T], BackendError> -> Void) -> Self {
        return response(queue: queue, responseSerializer: Request.ObjectMapperArraySerializer(keyPath), completionHandler: completionHandler)
    }
    
    func responseString(queue queue: dispatch_queue_t? = nil, keyPath: String? = nil, completionHandler: Response<String, BackendError> -> Void) -> Self {
        return response(queue: queue, responseSerializer: Request.S4SStringSearializer(keyPath), completionHandler: completionHandler)
    }
    
    static func S4SStringSearializer(keyPath: String?) -> ResponseSerializer<String, BackendError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else { return .Failure(.Network(error: error!)) }
            
            guard let _ = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                return .Failure(.DataSerialization(reason: failureReason))
            }
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            
            guard let code = result.value?.valueForKeyPath("code") as? Int else {return .Failure(.DataSerialization(reason:"sever replay error"))}
            
            let msg = result.value?.valueForKeyPath("msg") as? String ?? "unknow server error"
            
            if code > 0 {
                if code > 40000 && code < 50000 {
                    NSNotificationCenter.defaultCenter().postNotificationName("NeedLoginNotif", object: nil)
                }
                return .Failure(.BussinessError(code:code, msg:msg))
            }
            
            if let string = result.value?.valueForKeyPath("data") as? String {
                return .Success(string)
            }
            
            return .Failure(.DataSerialization(reason: "object mapper failed"))
        }
    }
    
    static func S4SMapperSerializer<T: Mappable>(keyPath: String?, mapToObject object: T? = nil) -> ResponseSerializer<T, BackendError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else { return .Failure(.Network(error: error!)) }
            
            guard let _ = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                return .Failure(.DataSerialization(reason: failureReason))
            }

            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            
            guard let code = result.value?.valueForKeyPath("code") as? Int else {return .Failure(.DataSerialization(reason:"sever replay error"))}
            
            let msg = result.value?.valueForKeyPath("msg") as? String ?? "unknow server error"
            
            if code > 0 {
                if code > 40000 && code < 50000 {
                    NSNotificationCenter.defaultCenter().postNotificationName("NeedLoginNotif", object: nil)
                }
                return .Failure(.BussinessError(code:code, msg:msg))
            }
            
            let JSONToMap: AnyObject?
            if let keyPath = keyPath where keyPath.isEmpty == false {
                JSONToMap = result.value?.valueForKeyPath("data")?.valueForKeyPath(keyPath)
            } else {
                JSONToMap = result.value?.valueForKeyPath("data")
            }
            
            if let object = object {
                Mapper<T>().map(JSONToMap, toObject: object)
                return .Success(object)
            } else if let parsedObject = Mapper<T>().map(JSONToMap){
                return .Success(parsedObject)
            }
            
            return .Failure(.DataSerialization(reason: "object mapper failed"))
        }
    }
    
    
    static func ObjectMapperArraySerializer<T: Mappable>(keyPath: String?) -> ResponseSerializer<[T], BackendError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .Failure(.Network(error: error!))
            }
            
            guard let _ = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                return .Failure(.DataSerialization(reason: failureReason))
            }
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            
            guard let code = result.value?.valueForKeyPath("code") as? Int else {return .Failure(.DataSerialization(reason:"sever replay error"))}
            
            let msg = result.value?.valueForKeyPath("msg") as? String ?? "unknow server error"
            
            if code > 0 {
                if code > 40000 && code < 50000 {
                    NSNotificationCenter.defaultCenter().postNotificationName("NeedLoginNotif", object: nil)
                }
                return .Failure(.BussinessError(code:code, msg:msg))
            }
            
            let JSONToMap: AnyObject?
            if let keyPath = keyPath where keyPath.isEmpty == false {
                JSONToMap = result.value?.valueForKeyPath("data")?.valueForKeyPath(keyPath)
            } else {
                JSONToMap = result.value?.valueForKeyPath("data")
            }
            
            if JSONToMap is NSNull {
                 return .Success([])
            }
            if let parsedObject = Mapper<T>().mapArray(JSONToMap){
                return .Success(parsedObject)
            }
            return .Failure(.DataSerialization(reason: "ObjectMapper failed to serialize response"))
        }
    }
}
