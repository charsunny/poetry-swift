//
//  DataManager.swift
//  poetry
//
//  Created by 诺崇 on 16/5/11.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import SQLite

public typealias Period = (
    id : Int,
    name : String
)

public typealias Dict = (
    key : String,
    explain : String,
    note : String
)

public typealias SQLStringExp = Expression<String>

public typealias SQLStringOExp = Expression<String?>

public typealias SQLIntExp = Expression<Int>

public typealias SQLiteRow = Row

public class DataManager: NSObject {
    
    public static var manager:DataManager = DataManager()
    
    private var db:Connection?
    private var poems:Table = Table("poem")
    private var poets:Table = Table("poet")
    private var period:Table = Table("period")
    private var dict:Table = Table("dict")
    
    private let id = Expression<Int>("id")
    private let name = Expression<String>("name_cn")
    private let desc = Expression<String?>("description_cn")
    private let content = Expression<String?>("text_cn")
    public var periods:[Int:String] = [:]
    
    private override init() {
        super.init()
    }
    
    public func connect() -> Bool {
        do {
            db = try Connection("\(DocumentPath)/poem.db")
            if let ps = try db?.prepare(period) {
                for p in ps {
                    periods[p[id]] = p[name]
                }
            }
            return true
        } catch let e {
            print(e)
            return false
        }
    }
    
    public func explain(key:String) -> String? {
        do {
            if let ps = try db?.prepare(dict.filter(Expression<String>("zi") == key)) {
                for p in ps {
                    let str = p[Expression<String?>("jijie")]
                    return str?.stringByReplacingOccurrencesOfString("<br />", withString: "\n")
                }
            }
            return nil
        } catch {
            return nil
        }
    }
    
    public func poemById(id: Int) -> Poem? {
        do {
            if let ps = try db?.prepare(poems.filter(self.id == id)) {
                for p in ps {
                    return Poem(p)
                }
            }
            return nil
        } catch {
            return nil
        }
    }
    
    public func poemByRowId(id: Int) -> Poem? {
        do {
            if let ps = try db?.prepare(poems.limit(1, offset: id)) {
                for p in ps {
                    return Poem(p)
                }
            }
            return nil
        } catch {
            return nil
        }
    }
    
    public func poetById(id: Int) -> Poet? {
        do {
            if let ps = try db?.prepare(poets.filter(self.id == id)) {
                for p in ps {
                    return Poet(p)
                }
            }
            return nil
        } catch {
            return nil
        }
    }
    
    public func poetByRowId(id: Int) -> Poet? {
        do {
            if let ps = try db?.prepare(poets.limit(1, offset: id)) {
                for p in ps {
                    return Poet(p)
                }
            }
            return nil
        } catch {
            return nil
        }
    }
    
    public func poemsByAuthor(id: Int) -> [Poem] {
        var poemlist:[Poem] = []
        do {
            if let ps = try db?.prepare(poems.filter(Expression<Int>("poet_id") == id)) {
                for p in ps {
                    let poem = Poem(p)
                    poemlist.append(poem)
                }
            }
            return poemlist
        } catch {
            return poemlist
        }
    }
}

extension String {
    func pinyin() -> String {
        let mstr = NSMutableString(string:self)
        CFStringTransform(mstr, nil, kCFStringTransformMandarinLatin, false)
        CFStringTransform(mstr, nil, kCFStringTransformStripCombiningMarks, false)
        return mstr.stringByReplacingOccurrencesOfString(" ", withString: "")
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
        var str = self.stringByReplacingOccurrencesOfString("\r\n", withString: "")
        str = str.stringByReplacingOccurrencesOfString("\n", withString: "")
        return str
    }
}

extension UIFont {
    public class func userFontWithSize(size:CGFloat) -> UIFont {
        return UIFont(name: UserFont, size: size)!
    }
}
