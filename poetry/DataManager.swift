//
//  DataManager.swift
//  poetry
//
//  Created by 诺崇 on 16/5/11.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import FMDB

public typealias Period = (
    id : Int,
    name : String
)

public typealias Dict = (
    key : String,
    explain : String,
    note : String
)

public typealias SQLiteRow = FMResultSet

open class DataManager: NSObject {
    
    open static var manager:DataManager = DataManager()
    
    fileprivate var db:FMDatabase?
    
    open var periods:[Int:String] = [:]
    open var formatDict:[String:Int] = [:]
    
    fileprivate override init() {
        super.init()
    }
    
    open func connect() -> Bool {
        
        guard let db = FMDatabase(path: "\(DocumentPath)/poem.db") else {
            print("unable to create database")
            return false
        }
        guard db.open() else {
            print("Unable to open database")
            return false
        }
        self.db = db
        do {
            let rs = try db.executeQuery("select * from period where id > 0", values: nil)
            while rs.next() {
                let id = rs.long(forColumn: "id")
                let name = rs.string(forColumn: "name") ?? ""
                periods[id] = name
            }
            let ps = try db.executeQuery("select * from poem_format where type = ?", values: [0])
            while ps.next() {
                let id = rs.long(forColumn: "id")
                let name = rs.string(forColumn: "name_cn") ?? ""
                formatDict[name] = id
            }
        } catch let (e) {
            debugPrint(e)
            return false
        }
       
        /*
        do {
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
        }*/
        return true
    }
    
    open func search(_ text:String) -> [Poem] {
        do {
            var list:[Poem] = []
            if let ps = try db?.executeQuery("select * from ps where text_cn match ? limit 20", values: [text+"*"]) {
                while ps.next() {
                    let poem = Poem(ps, hasName: true)
                    list.append(poem)
                }
            }
            return list
        } catch {
            return []
        }
    }
    
    open func searchFormat(_ text: String) -> [PoemFormat] {
        return formatDict.keys.filter { $0.contains(text)}.map { (key) -> PoemFormat in
            return self.formatById(self.formatDict[key]!)!
        }
    }
    
    open func searchAuthor(_ text:String) -> [Poet] {
        do {
            var list:[Poet] = []
            var pnames:Set<String> = []
            if let ps = try db?.executeQuery("select * from ps where poet_name match ? limit 20", values: [text+"*"]) {
                while ps.next() {
                    let name = ps.string(forColumn: "poet_name") ?? ""
                    pnames.insert(name)
                }
            }
            for name in pnames {
                list.append(contentsOf: poetByName(name))
            }
            return list
        } catch {
            return []
        }
    }
    
    
    
    open func explain(_ key:String) -> String? {
        do {
            /*if let ps = try db?.prepare(dict.filter(Expression<String>("zi") == key)) {
                for p in ps {
                    let str = p[Expression<String?>("jijie")]
                    return str?.stringByReplacingOccurrencesOfString("<br />", withString: "\n")
                }
            }*/
            return nil
        } catch {
            return nil
        }
    }
    
    open func formatById(_ id: Int) -> PoemFormat? {
        do {
            if let ps = try db?.executeQuery("select * from poem_format where id = ?", values: [id]) {
                while ps.next() {
                    return PoemFormat(ps)
                }
            }
            return nil
        } catch {
            return nil
        }
    }
    
    open func formatByRowId(_ id: Int) -> PoemFormat? {
        do {
            if let ps = try db?.executeQuery("select * from poem_format where row_id = ?", values: [id]) {
                while ps.next() {
                    return PoemFormat(ps)
                }
            }
            return nil
            return nil
        } catch {
            return nil
        }
    }

    
    open func poemById(_ id: Int) -> Poem? {
        do {
            if let ps = try db?.executeQuery("select * from poem where id = ?", values: [id]) {
                while ps.next() {
                    return Poem(ps)
                }
            }
            return nil
        } catch {
            return nil
        }
    }
    
    open func poemByRowId(_ id: Int) -> Poem? {
        do {
            if let ps = try db?.executeQuery("select * from poem where row_id = ?", values: [id]) {
                while ps.next() {
                    return Poem(ps)
                }
            }
            return nil
        } catch {
            return nil
        }
    }
    
    open func poetById(_ id: Int) -> Poet? {
        do {
            if let ps = try db?.executeQuery("select * from poet where id = ?", values: [id]) {
                while ps.next() {
                    return Poet(ps)
                }
            }
            return nil
        } catch {
            return nil
        }
    }
    
    open func poetByName(_ str: String) -> [Poet] {
        do {
            var pts:[Poet] = []
            if let ps = try db?.executeQuery("select * from poet where name_cn = ?", values: [str]) {
                while ps.next() {
                    pts.append(Poet(ps))
                }
            }
            return pts
        } catch {
            return []
        }
    }
    
    open func poetByRowId(_ id: Int) -> Poet? {
        do {
            if let ps = try db?.executeQuery("select * from poet where row_id = ?", values: [id]) {
                while ps.next() {
                    return Poet(ps)
                }
            }
            return nil
        } catch {
            return nil
        }
    }
    
    open func poemsByAuthor(_ id: Int) -> [Poem] {
        var poemlist:[Poem] = []
        do {
            if let ps = try db?.executeQuery("select * from poem where poet_id = ?", values: [id]) {
                while ps.next() {
                    let poem = Poem(ps)
                    poemlist.append(poem)
                }
            }
            return poemlist
        } catch {
            return poemlist
        }
    }
    
    open func poemsByFormat(_ id: Int) -> [Poem] {
        var poemlist:[Poem] = []
        do {
            if let ps = try db?.executeQuery("select * from poem where format_id = ?", values: [id]) {
                while ps.next() {
                    let poem = Poem(ps)
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

extension UIFont {
    public class func userFont(size:CGFloat) -> UIFont {
        if User.Font == "system" {
            return UIFont.systemFont(ofSize: size, weight: UIFontWeightRegular)
        }
        return UIFont(name: User.Font, size: size)!
    }
}
