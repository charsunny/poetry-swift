//
//  TodayViewController.swift
//  today
//
//  Created by sunsing on 9/18/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var authorImageView: UIImageView!
    
    @IBOutlet weak var excerptLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var content:String? {
        didSet {
            DispatchQueue.main.async {
                self.excerptLabel.text = self.content
                 UserDefaults(suiteName: "group.com.charsunny.poetry")?.set(self.content, forKey: "group.com.charsunny.poetry.wc")
            }
        }
    }
    
    var subtitle:String? {
        didSet {
            DispatchQueue.main.async {
                self.authorLabel.text = self.subtitle
                UserDefaults(suiteName: "group.com.charsunny.poetry")?.set(self.subtitle, forKey: "group.com.charsunny.poetry.wdesc")
            }
        }
    }
    
    var poetId : Int {
        set {
            UserDefaults(suiteName: "group.com.charsunny.poetry")?.set(newValue, forKey: "group.com.charsunny.poetry.poet")
        }
        get {
            return UserDefaults(suiteName: "group.com.charsunny.poetry")?.integer(forKey: "group.com.charsunny.poetry.poet") ?? 0
        }
    }
    
    var poemId : Int {
        set {
            UserDefaults(suiteName: "group.com.charsunny.poetry")?.set(newValue, forKey: "group.com.charsunny.poetry.poem")
        }
        get {
            return UserDefaults(suiteName: "group.com.charsunny.poetry")?.integer(forKey: "group.com.charsunny.poetry.poem") ?? 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateWidget()
    }
    
    func updateWidget() {
        nameLabel.isHidden = true
        self.authorImageView.isHidden = false
        if let content = UserDefaults(suiteName: "group.com.charsunny.poetry")?.string(forKey: "group.com.charsunny.poetry.wc") {
            self.excerptLabel.text = content
        }
        if let desc = UserDefaults(suiteName: "group.com.charsunny.poetry")?.string(forKey: "group.com.charsunny.poetry.wdesc") {
            self.authorLabel.text = desc
        }
        URLSession.shared.dataTask(with: URL(string:"http://192.168.3.17:8080/v1/rec/today")!) { (data, _, err) in
            guard let data = data else {return}
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                    if let code = json["errcode"] as? Int, code == 0 {
                        if let excerpt = json["data"] as? NSDictionary {
                            self.content = excerpt["Content"] as? String ?? "暂无今日诗词推荐"
                            var tmpStr = ""
                            if let poem = excerpt["Poem"] as? NSDictionary {
                                if let poet = poem["Poet"] as? NSDictionary {
                                    if let name = poet["Name"] as? String, name.characters.count > 0 {
                                        tmpStr += name + "◦"
                                        DispatchQueue.global().async {
                                            do {
                                                let imageData = try Data(contentsOf:URL(string:name.iconURL())!)
                                                if let image = UIImage(data: imageData) {
                                                    DispatchQueue.main.async {
                                                        self.authorImageView.image = image
                                                    }
                                                } else {
                                                    DispatchQueue.main.async {
                                                        self.authorImageView.isHidden = true
                                                        self.nameLabel.isHidden = false
                                                        self.nameLabel.text = name
                                                    }
                                                }
                                            } catch {
                                                DispatchQueue.main.async {
                                                    self.authorImageView.isHidden = true
                                                    self.nameLabel.isHidden = false
                                                    self.nameLabel.text = name
                                                }
                                            }
                                        }
                                        
                                    } else {
                                        self.authorImageView.isHidden = true
                                    }
                                    self.poetId = poet["Id"] as? Int ?? 0
                                }
                                self.poemId = poem["Id"] as? Int ?? 0
                                if let title = poem["Name"] as? String {
                                    tmpStr += title
                                }
                            }
                            self.subtitle = tmpStr
                        }
                    }
                }
            } catch {
                
            }
            }.resume()
    }
    
    @IBAction func gotoApp(_ sender: AnyObject) {
        extensionContext?.open(URL(string:"poem://poet/\(poetId)")!, completionHandler: nil)
    }
    
    @IBAction func gotoPoem(_ sender: AnyObject) {
        extensionContext?.open(URL(string:"poem://poem/\(poemId)")!, completionHandler: nil)
    }
    
    private func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        updateWidget()
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
