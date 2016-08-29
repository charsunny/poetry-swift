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

public class Recommend: Mappable {
    
    static func GetRec(id:Int = 0, finish:(Recommend?, BackendError?)->Void) {
        Alamofire.request(Router.Recommend(.GET, "info", ["rid":id])).responseObject { (res:Response<Recommend, BackendError>) in
            res.result.success({ (value) in
                finish(value, nil)
            }).failure({ (error) in
                finish(nil, error)
            })
        }
    }
    
    static func GetRecList(page:Int, finish:([Recommend], BackendError?)->Void) {
        Alamofire.request(Router.Recommend(.GET, "list", ["page":page])).responseArray { (res:Response<[Recommend], BackendError>) in
            res.result.success({ (value) in
                finish(value, nil)
            }).failure({ (error) in
                finish([], error)
            })
        }
    }
    
    var id   : Int = 0
    var title : String = ""
    var desc	: String = ""
    var time  : String = ""
    var poems : [Poem] = []
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id <- map["Id"]
        title <- map["Title"]
        desc <- map["Desc"]
        time <- map["Time"]
        poems <- map["Poems"]
    }
}
