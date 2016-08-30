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

public class PoemFormat: Mappable {
    var id   : Int = 0
    var name : String = ""
    var desc	: String = ""
    
    required public init?(_ map: Map) {
        
    }
    
    public init(_ row:SQLiteRow) {
        id = row.get(SQLIntExp("id"))
        name = row.get(SQLStringExp("name_cn"))
        desc = row.get(SQLStringOExp("description_cn")) ?? ""
    }
    
    public func mapping(map: Map) {
        id <- map["Id"]
        name <- map["Name"]
        desc <- map["Desc"]
    }
}

public class Poem: Mappable {
    
    static func GetPoemDetail(id:Int, finish:(Poem?, BackendError?)->Void) {
        Alamofire.request(Router.Poem(.GET, "\(id)", ["local":LocalDBExist])).responseObject { (res:Response<Poem, BackendError>) in
            res.result.success({ (value) in
                finish(value, nil)
            }).failure({ (error) in
                finish(nil, error)
            })
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
    private var pid :Int = 0
    private var fid :Int = 0
    var pname : String?
    required public init?(_ map: Map) {
        
    }
    
    public init(_ row:SQLiteRow, hasName name:Bool = false) {
        id = row.get(SQLIntExp("id"))
        title = row.get(SQLStringExp("name_cn"))
        content = row.get(SQLStringExp("text_cn"))
        if !name {
            pid = row[SQLIntOExp("poet_id")] ?? 0
            fid = row[SQLIntOExp("format_id")] ?? 0
            format = DataManager.manager.formatById(fid)?.name ?? ""
        } else {
            pname = row[SQLStringOExp("poet_name")]
        }
    }
    
    public func loadPoet() {
        if pid > 0 {
            poet = DataManager.manager.poetById(pid)
        } else if let pname = pname {
            poet = DataManager.manager.poetByName(pname).first
        }
    }
    
    public func mapping(map: Map) {
        id <- map["Id"]
        title <- map["Name"]
        content <- map["Text"]
        format <- map["Format"]
        poet <- map["Poet"]
        commentCount <- map["CommentCount"]
        likeCount <- map["LikeCount"]
        isFav <- map["IsFav"]
    }
    
    func like(finish:(String, BackendError?)->Void) {
        Alamofire.request(Router.Poem(.POST, "like", ["pid":self.id])).responseString { (res:Response<String, BackendError>) in
            res.result.success({ (value) in
                if value.containsString("取消") {
                    self.isFav = false
                    if self.likeCount > 0 {
                        self.likeCount = self.likeCount - 1
                    }
                } else {
                    self.isFav = true
                    self.likeCount = self.likeCount + 1
                }
                 finish(value, nil)
            }).failure({ (error) in
                finish("", error)
            })
        }
    }
}
