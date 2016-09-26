//
//  Column.swift
//  poetry
//
//  Created by sunsing on 9/20/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

class Column: Mappable {
    
    static func AddColumn(name:String, desc:String, image:String, type:Int, pids:String, finish: @escaping (Column?, Error?) -> Void) {
        Alamofire.request(Router.column(.post, "create", ["name":name, "desc":desc, "image":image, "type":type, "contents":pids])).responseObject { (res:DataResponse<Column>) in
            switch res.result {
            case .success(let col):
                finish(col, nil)
            case .failure(let err):
                finish(nil, err)
            }
        }
    }
    
    static func UpdateItem(_ id:Int, pid:Int, finish:@escaping (Bool, Error?) -> Void) {
        Alamofire.request(Router.column(.post, "updateitem", ["cid":id, "pid":pid])).responseJSON { (res:DataResponse<Any>) in
            switch res.result {
            case .success(let data):
                if let dict = data as? NSDictionary{
                    if let code = dict["errcode"] as? Int, code == 0 {
                        if let msg = dict["data"] as? String {
                            if msg.contains("Delete") {
                                finish(true, nil)
                            } else {
                                finish(false, nil)
                            }
                            return
                        }
                    }
                }
                finish(false, NSError(domain: "", code: 100, userInfo: nil))
            case .failure(let err):
                finish(false, err)
            }
        }
    }
    
    static func GetDetail(_ id: Int, finish:@escaping (Column?, Error?)->Void) {
        Alamofire.request(Router.column(.get, "\(id)", [:])).responseObject { (res:DataResponse<Column>) in
            switch res.result {
            case .success(let col):
                finish(col, nil)
            case .failure(let err):
                finish(nil, err)
            }
        }
    }
    
    static func GetUserColumnList(_ page:Int = 0, uid:Int, finish:@escaping ([Column], Error?)->Void) {
        Alamofire.request(Router.column(.get, "user", ["id":uid])).responseArray { (res:DataResponse<[Column]>) in
            switch res.result {
            case .success(let list):
                finish(list, nil)
            case .failure(let err):
                finish([], err)
            }
        }
    }
    
    static func GetUserFavColumnList(_ page:Int = 0, uid:Int, finish:@escaping ([Column], Error?)->Void) {
        Alamofire.request(Router.column(.get, "userfav", ["id":uid])).responseArray { (res:DataResponse<[Column]>) in
            switch res.result {
            case .success(let list):
                finish(list, nil)
            case .failure(let err):
                finish([], err)
            }
        }
    }
    
    func getComments(page:Int, finish:@escaping ([Comment], Error?)->Void) {
        Alamofire.request(Router.feed(.get, "comments", ["cid":self.id, "page":page])).responseArray { (res:DataResponse<[Comment]>) in
            switch res.result {
            case let .success(value):
                finish(value, nil)
            case let .failure(error):
                finish([], error)
            }
        }
    }
    
    var id     :    Int = 0
    var title  :    String = ""
    var desc   :      String = ""
    var image   :     String = ""
    var type  :       Int  = 0      // 0 表示诗歌 1 表示诗人
    var delete  :     Int  = 0     //是否标记为删除
    var `default` :     Bool  = false     // 是否是默认专辑，默认不可以删除
    var user   :      User?      //创建人
    //Poets        []*Poet    `orm:"rel(m2m)"`
    //Poems        []*Poem    `orm:"rel(m2m)"`
    var isFav   :     Bool = false
    var count   :     Int  = 0      // 作品数量
    var likeCount :   Int  = 0      // 收藏人数
    var commentCount : Int = 0       // 评论人数
    
    var poets : [Poet]?
    
    var poems : [Poem]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["Id"]
        title <- map["Title"]
        desc <- map["Desc"]
        image <- map["Image"]
        type <- map["Type"]
        delete <- map["Delete"]
        `default` <- map["Default"]
        isFav <- map["IsFav"]
        count <- map["Count"]
        likeCount <- map["LikeCount"]
        commentCount <- map["CommentCount"]
        user <- map["User"]
        poems <- map["Poems"]
        poets <- map["Poets"]
    }
    
}
