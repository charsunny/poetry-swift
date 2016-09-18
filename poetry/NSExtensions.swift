//
//  NSExtensions.swift
//  poetry
//
//  Created by sunsing on 9/18/16.
//  Copyright © 2016 诺崇. All rights reserved.
//
import Foundation

extension String {
    func pinyin() -> String {
        let mstr = NSMutableString(string:self)
        CFStringTransform(mstr, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(mstr, nil, kCFStringTransformStripCombiningMarks, false)
        return mstr.replacingOccurrences(of: " ", with: "")
    }
    
    func iconURL() -> String {
        return "http://img.gushiwen.org/authorImg/" + self.pinyin() + ".jpg"
    }
    
    func isHanZi() -> Bool {
        if let c = self.characters.first {
            if c >= "\u{4e00}" && c <= "\u{9fa5}" {
                return true
            }
        }
        return false
    }
    
    func trimString() -> String {
        var str = self.replacingOccurrences(of: "\r\n", with: "")
        str = str.replacingOccurrences(of: "\n", with: "")
        return str
    }
}
