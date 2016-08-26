//
//  Error.swift
//  S4SShopClient
//
//  Created by 诺崇 on 16/6/15.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

enum BackendError: ErrorType {
    case Network(error: NSError)
    case DataSerialization(reason: String)
    case JSONSerialization(error: NSError)
    case ObjectSerialization(reason: String)
    case BussinessError(code:Int, msg:String)
}

extension String {
    static func ErrorString(err:BackendError) -> String {
        switch err {
        case .Network:
            return "网络链接失败，请稍候重试"
        case let .DataSerialization(str):
            return str
        case let .JSONSerialization(error):
            return error.description
        case let .ObjectSerialization(str):
            return str
        case let .BussinessError(_, str):
            return str
        }
    }
}