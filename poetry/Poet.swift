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

open class Poet: Mappable {
    var id   : Int = 0
    var name : String = ""
    var avatar : String = ""
    var desc	: String = ""
    var period  : String = ""
    
    var likeCount : Int = 0
    var isFav:Bool = false
    
    var poems : [Poem] = []
    
    required public init?(map: Map) {
        
    }
    
    public init(_ row:SQLiteRow) {
        id = row.long(forColumn:"id")
        name = row.string(forColumn:"name_cn") ?? ""
        desc = row.string(forColumn:"description_cn") ?? ""
        let pid = row.long(forColumn:"period_id")
        period = DataManager.manager.periods[pid] ?? ""
    }
    
    open func mapping(map: Map) {
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
