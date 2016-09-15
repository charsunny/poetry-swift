//
//  Comment.swift
//  poetry
//
//  Created by sunsing on 8/29/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class Comment: Mappable {
    
    var id   : Int = 0
    var user : User?
    var content	: String = ""
    var time  : String = ""
    var likeCount : Int = 0
    var comment : Comment?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["Id"]
        likeCount <- map["LikeCount"]
        content <- map["Content"]
        time <- map["Time"]
        user <- map["User"]
        comment <- map["Comment"]
    }
}
