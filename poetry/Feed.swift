//
//  Feed.swift
//  poetry
//
//  Created by sunsing on 8/31/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class Feed: Mappable {
    
    static func AddFeed(pid : Int, content:String, image:String, finish:(Bool, BackendError?)->Void) {
        let param:[String:AnyObject] = ["pid":pid, "content":content, "image":image]
        Alamofire.request(Router.User(.POST, "addfeed", param)).responseString { (res :Response<String, BackendError>) in
            res.result.success({ (value) in
                finish(true, nil)
            }).failure({ (error) in
                finish(false, error)
            })
        }
    }
    
    static func GetFeeds(page : Int, finish:([Feed], BackendError?)->Void) {
        Alamofire.request(Router.Feed(.GET, "list", ["page":page])).responseArray { (res :Response<[Feed], BackendError>) in
            res.result.success({ (value) in
                finish(value, nil)
            }).failure({ (error) in
                finish([], error)
            })
        }
    }
    
    static func GetFeedsAfter(fid : Int, finish:([Feed], BackendError?)->Void) {
        Alamofire.request(Router.Feed(.GET, "list", ["fid":fid])).responseArray { (res :Response<[Feed], BackendError>) in
            res.result.success({ (value) in
                finish(value, nil)
            }).failure({ (error) in
                finish([], error)
            })
        }
    }
    
    static func GetUserFeeds(page : Int, finish:([Feed], BackendError?)->Void) {
        Alamofire.request(Router.User(.GET, "feeds", ["page":page])).responseArray { (res :Response<[Feed], BackendError>) in
            res.result.success({ (value) in
                finish(value, nil)
            }).failure({ (error) in
                finish([], error)
            })
        }
    }
    
    var id   : Int = 0
    var content : String = ""
    var picture	: String = ""
    var user : User?
    var time : String = ""
    var poem  : Poem?
    var likeCount : Int = 0
    var commentCount : Int = 0
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["Id"]
        picture <- map["Picture"]
        content <- map["Content"]
        user <- map["User"]
        time <- map["Time"]
        poem <- map["Poem"]
        likeCount <- map["likeCount"]
        commentCount <- map["CommentCount"]
    }
}
