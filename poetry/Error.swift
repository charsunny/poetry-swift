//
//  Error.swift
//  S4SShopClient
//
//  Created by 诺崇 on 16/6/15.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

enum BackendError: Error {
    case network(error: NSError)
    case dataSerialization(reason: String)
    case jsonSerialization(error: NSError)
    case objectSerialization(reason: String)
    case bussinessError(code:Int, msg:String)
}

extension String {
    static func ErrorString(_ err:BackendError) -> String {
        switch err {
        case .network:
            return "网络链接失败，请稍候重试"
        case let .dataSerialization(str):
            return str
        case let .jsonSerialization(error):
            return error.description
        case let .objectSerialization(str):
            return str
        case let .bussinessError(_, str):
            return str
        }
    }
}
