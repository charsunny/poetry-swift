//
//  Recommend.swift
//  poetry
//
//  Created by sunsing on 8/28/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

open class TodayRecommend: Mappable {
    var id   : Int = 0
    var content : String = ""
    var time  : String = ""
    var poem : Poem?
    
    required public init?(map: Map) {
        
    }
    
    open func mapping(map: Map) {
        id <- map["Id"]
        content <- map["Content"]
        time <- map["Time"]
        poem <- map["Poem"]
        poem?.loadPoet()
    }
}

open class Recommend: Mappable {
    
    static func GetTodayRec(finish:@escaping (TodayRecommend?, Error?)->Void) {
        Alamofire.request(Router.recommend(.get, "today", [:])).responseObject { (res:DataResponse<TodayRecommend>) in
            switch res.result {
            case let .success(value):
                finish(value, nil)
            case let .failure(error):
                finish(nil, error)
            }
        }
    }
    
    static func GetRec(_ id:Int = 0, finish:@escaping (Recommend?, Error?)->Void) {
        Alamofire.request(Router.recommend(.get, "info", ["rid":id])).responseObject { (res:DataResponse<Recommend>) in
            switch res.result {
            case let .success(value):
                finish(value, nil)
            case let .failure(error):
                finish(nil, error)
            }
        }
    }
    
    static func GetRecList(_ page:Int, finish:@escaping ([Recommend], Error?)->Void) {
        Alamofire.request(Router.recommend(.get, "list", ["page":page])).responseArray { (res:DataResponse<[Recommend]>) in
            switch res.result {
            case let .success(value):
                finish(value, nil)
            case let .failure(error):
                finish([], error)
            }
        }
    }
    
    var id   : Int = 0
    var title : String = ""
    var desc	: String = ""
    var time  : String = ""
    var poems : [Poem] = []
    
    required public init?(map: Map) {
        
    }
    
    open func mapping(map: Map) {
        id <- map["Id"]
        title <- map["Title"]
        desc <- map["Desc"]
        time <- map["Time"]
        poems <- map["Poems"]
    }
}
