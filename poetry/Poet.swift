//
//  Poet.swift
//  poetry
//
//  Created by sunsing on 8/28/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

public class Poet: Mappable {
    var id   : Int = 0
    var name : String = ""
    var avatar : String = ""
    var desc	: String = ""
    var period  : String = ""
    
    var likeCount : Int = 0
    var isFav:Bool = false
    
    var poems : [Poem] = []
    
    required public init?(_ map: Map) {
        
    }
    
    public init(_ row:SQLiteRow) {
        id = row.get(SQLIntExp("id"))
        name = row.get(SQLStringExp("name_cn"))
        desc = row.get(SQLStringOExp("description_cn")) ?? ""
        let pid = row.get(SQLIntExp("period_id"))
        period = DataManager.manager.periods[pid] ?? ""
    }
    
    public func mapping(map: Map) {
        id <- map["Id"]
        name <- map["Name"]
        avatar <- map["Avatar"]
        desc <- map["Desc"]
        period <- map["Period"]
        poems <- map["Poems"]
        likeCount <- map["LikeCount"]
        isFav <- map["IsFav"]
    }
}
