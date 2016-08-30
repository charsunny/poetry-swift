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
public typealias SQLIntOExp = Expression<Int?>

public typealias SQLiteRow = Row

public class DataManager: NSObject {
    
    public static var manager:DataManager = DataManager()
    
    private var db:Connection?
    private var poems:Table = Table("poem")
    private var formats:Table = Table("poem_format")
    private var poets:Table = Table("poet")
    private var period:Table = Table("period")
    private var dict:Table = Table("dict")
    private let poemsearch:VirtualTable = VirtualTable("ps")
    
    private let id = Expression<Int>("id")
    private let name = Expression<String>("name_cn")
    private let desc = Expression<String?>("description_cn")
    private let content = Expression<String?>("text_cn")
    public var periods:[Int:String] = [:]
    public var formatDict:[String:Int] = [:]
    
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
            if let ps = try db?.prepare(formats.filter(SQLIntExp("type") == 0).filter(self.id == id)) {
                for p in ps {
                    formatDict[p[SQLStringExp("name_cn")]] = p[SQLIntExp("id")]
                }
            }
//            dispatch_async(dispatch_get_global_queue(0, 0)) {
//                do {
//                    try self.db?.run(self.poemsearch.create(.FTS4([SQLIntExp("id"), SQLStringExp("name_cn"), SQLStringExp("text_cn"), SQLStringExp("poet_name"), SQLIntExp("poet_id")], tokenize : Tokenizer.Simple)))
//                    if let pm = try self.db?.prepare(self.poems) {
//                        for p in pm {
//                            let poem = Poem(p)
//                            poem.loadPoet()
//                            try self.db?.run(self.poemsearch.insert(SQLIntExp("id") <- poem.id, SQLStringExp("name_cn") <- poem.title, SQLStringExp("text_cn") <- poem.content, SQLStringExp("poet_name") <- (poem.poet?.name ?? ""),SQLIntExp("id") <- (poem.poet?.id ?? 0)))
//                        }
//                    }
//                } catch let e {
//                    print(e)
//                }
//            }
            return true
        } catch let e {
            print(e)
            return false
        }
    }
    
    public func search(text:String) -> [Poem] {
        do {
            var list:[Poem] = []
            
            if let ps = try db?.prepare(poemsearch.match(text).limit(20)) {
                for p in ps {
                    let poem = Poem(p, hasName: true)
                    list.append(poem)
                }
            }
            return list
        } catch {
            return []
        }
    }
    
    public func searchFormat(text: String) -> [PoemFormat] {
        return formatDict.keys.filter { $0.containsString(text)}.map { (key) -> PoemFormat in
            return self.formatById(self.formatDict[key]!)!
        }
    }
    
    public func searchAuthor(text:String) -> [Poet] {
        do {
            var list:[Poet] = []
            var pnames:Set<String> = []
            if let ps = try db?.prepare(poemsearch.filter(SQLStringExp("poet_name").match(text)).limit(20)) {
                for p in ps {
                    let name = p[SQLStringExp("poet_name")]
                    pnames.insert(name)
                }
            }
            for name in pnames {
                list.appendContentsOf(poetByName(name))
            }
            return list
        } catch {
            return []
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
    
    public func formatById(id: Int) -> PoemFormat? {
        do {
            if let ps = try db?.prepare(formats.filter(self.id == id)) {
                for p in ps {
                    return PoemFormat(p)
                }
            }
            return nil
        } catch {
            return nil
        }
    }
    
    public func formatByRowId(id: Int) -> PoemFormat? {
        do {
            if let ps = try db?.prepare(formats.filter(SQLIntExp("type") == 0).limit(1, offset: id)) {
                for p in ps {
                    return PoemFormat(p)
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
    
    public func poetByName(str: String) -> [Poet] {
        do {
            var pts:[Poet] = []
            if let ps = try db?.prepare(poets.filter(self.name == str)) {
                for p in ps {
                    pts.append(Poet(p))
                }
            }
            return pts
        } catch {
            return []
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
