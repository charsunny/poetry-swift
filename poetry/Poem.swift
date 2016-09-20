//
//  Poem.swift
//  poetry
//
//  Created by sunsing on 8/28/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

open class PoemFormat: Mappable {
    var id   : Int = 0
    var name : String = ""
    var desc	: String = ""
    
    required public init?(map: Map) {
        
    }
    
    public init(_ row:SQLiteRow) {
        id = row.long(forColumn:"id")
        name = row.string(forColumn:"name_cn") ?? "" 
        desc = row.string(forColumn:"description_cn") ?? ""
    }
    
    open func mapping(map: Map) {
        id <- map["Id"]
        name <- map["Name"]
        desc <- map["Desc"]
    }
}

open class Poem: Mappable {
    
    static func GetPoemDetail(_ id:Int, finish:@escaping (Poem?, Error?)->Void) {
        Alamofire.request(Router.poem(.get, "\(id)", ["local":LocalDBExist])).responseObject { (res:DataResponse<Poem>) in
            switch res.result {
            case let .success(value):
                finish(value, nil)
            case let .failure(error):
                finish(nil, error)
            }
        }
    }
    
    var id   : Int = 0
    var title : String = ""
    var content	: String = ""
    var format  : String = ""
    var commentCount : Int = 0
    var likeCount : Int = 0
    var isFav:Bool = false
    var poet : Poet?
    fileprivate var pid :Int = 0
    fileprivate var fid :Int = 0
    var pname : String?
    required public init?(map: Map) {
        
    }
    
    public init(_ row:SQLiteRow, hasName name:Bool = false) {
        id = row.long(forColumn:"id")
        title = row.string(forColumn: "name_cn") ?? ""
        content = row.string(forColumn:  "text_cn") ?? ""
        if !name {
            pid = row.long(forColumn:"poet_id")
            fid = row.long(forColumn:"format_id")
            format = DataManager.manager.formatById(fid)?.name ?? ""
        } else {
            pname = row.string(forColumn:"poet_name")
        }
    }
    
    open func loadPoet() {
        if pid > 0 {
            poet = DataManager.manager.poetById(pid)
        } else if let pname = pname {
            poet = DataManager.manager.poetByName(pname).first
        } else if let poet = poet {
            if poet.name.characters.count == 0 {
                self.poet = DataManager.manager.poetById(poet.id)
            }
        }
    }
    
    open func mapping(map: Map) {
        id <- map["Id"]
        title <- map["Name"]
        content <- map["Text"]
        format <- map["Format"]
        poet <- map["Poet"]
        commentCount <- map["CommentCount"]
        likeCount <- map["LikeCount"]
        isFav <- map["IsFav"]
    }
    
    func like(_ finish:@escaping (String, Error?)->Void) {
        Alamofire.request(Router.poem(.post, "like", ["pid":self.id])).responseJSON { (res:DataResponse<Any>) in
            switch res.result {
            case let .success(value):
                if let str =  (value as? NSDictionary)?["data"] as? String {
                    if str.contains("取消") {
                        self.isFav = false
                        if self.likeCount > 0 {
                            self.likeCount = self.likeCount - 1
                        }
                    } else {
                        self.isFav = true
                        self.likeCount = self.likeCount + 1
                    }
                    finish(str, nil)
                }
            case let .failure(error):
                finish("", error)
            }
        }
    }
}
