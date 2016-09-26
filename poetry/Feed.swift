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
    
    static func AddFeed(_ pid : Int, content:String, image:String, finish:@escaping (Bool, Error?)->Void) {
        let param:[String:AnyObject] = ["pid":pid as AnyObject, "content":content as AnyObject, "image":image as AnyObject]
        Alamofire.request(Router.user(.post, "addfeed", param)).responseString { (res :DataResponse<String>) in
            switch res.result {
            case .success:
                finish(true, nil)
            case let .failure(error):
                finish(false, error)
            }
        }
    }
    
    static func GetFeeds(_ page : Int, finish:@escaping ([Feed], Error?)->Void) {
        Alamofire.request(Router.feed(.get, "list", ["page":String(page)])).responseArray { (res :DataResponse<[Feed]>) in
            switch res.result {
            case let .success(value):
                finish(value, nil)
            case let .failure(error):
                finish([], error)
            }
        }
    }
    
    static func GetFeedsAfter(_ fid : Int, finish:@escaping ([Feed], Error?)->Void) {
        Alamofire.request(Router.feed(.get, "list", ["fid":fid])).responseArray { (res :DataResponse<[Feed]>) in
            switch res.result {
            case let .success(value):
                finish(value, nil)
            case let .failure(error):
                finish([], error)
            }
        }
    }
    
    static func GetUserFeeds(_ page : Int, uid : Int = 0, finish:@escaping ([Feed], Error?)->Void) {
        Alamofire.request(Router.user(.get, "feeds", ["page":page, "id":uid])).responseArray { (res :DataResponse<[Feed]>) in
            switch res.result {
            case let .success(value):
                finish(value, nil)
            case let .failure(error):
                finish([], error)
            }
        }
    }
    
    static func GetUserFeedsAfter(_ fid : Int, uid : Int = 0, finish:@escaping ([Feed], Error?)->Void) {
        Alamofire.request(Router.user(.get, "feeds", ["fid":fid, "id":uid])).responseArray { (res :DataResponse<[Feed]>) in
            switch res.result {
            case let .success(value):
                finish(value, nil)
            case let .failure(error):
                finish([], error)
            }
        }
    }
    
    func getComments(page:Int, finish:@escaping ([Comment], Error?)->Void) {
        Alamofire.request(Router.feed(.get, "comments", ["fid":self.id, "page":page])).responseArray { (res:DataResponse<[Comment]>) in
            switch res.result {
            case let .success(value):
                finish(value, nil)
            case let .failure(error):
                finish([], error)
            }
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
    var isFav : Bool = false
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["Id"]
        picture <- map["Picture"]
        content <- map["Content"]
        user <- map["User"]
        time <- map["Time"]
        poem <- map["Poem"]
        isFav <- map["IsFav"]
        likeCount <- map["LikeCount"]
        commentCount <- map["CommentCount"]
    }
}
