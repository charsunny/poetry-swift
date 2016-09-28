//
//  Search.swift
//  poetry
//
//  Created by sunsing on 9/27/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class Search: Mappable {
    
    var poets : [Poet] = []
    var poet  : Poet?
    var poem : Poem?
    var format: PoemFormat?
    
    required public init?(map: Map) {
        
    }
    
    open func mapping(map: Map) {
        poets <- map["poets"]
        poet <- map["poet"]
        poem <- map["poem"]
        format <- map["format"]
        poem?.loadPoet()
    }
    
    static func GetSearchIndex(_ finish:@escaping (Search?, Error?)->Void) {
        Alamofire.request(Router.base(.get, "search", [:])).responseObject { (res :DataResponse<Search>) in
            switch res.result {
            case let .success(value) :
                finish(value, nil)
            case let .failure(error):
                finish(nil, error)
            }
        }
    }
}
