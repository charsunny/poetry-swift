//
//  FirstViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/10.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import IBAnimatable
import NVActivityIndicatorView
import SwiftyJSON
import Alamofire
import SSZipArchive
import JDStatusBarNotification
import AlamofireImage

class RecommendViewController: UITableViewController {
    
    @IBOutlet var headerView: RecommandHeaderView!
    
    var poems:[Poem] = []
    
    var recInfo:NSDictionary? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = nil
        headerView.titleLabel.text = " "
        headerView.descLabel.text = "正在加载推荐信息..."
        if recInfo != nil {
            headerView.titleLabel.text = recInfo!["Title"] as? String ?? ""
            headerView.timeLabel.text = recInfo!["Time"] as? String ?? ""
            headerView.descLabel.text = recInfo!["Desc"] as? String ?? ""
            loadPoemData(recInfo!["Id"] as! Int)
            navigationItem.rightBarButtonItem = nil
            navigationItem.leftBarButtonItem = nil
        } else {
            loadPoemData()
        }
        headerView.indicatorView.startAnimation()
        
        if !LocalDBExist {
            let alertController = UIAlertController(title: "下载诗词数据", message: "检测到诗词数据库文件尚未下载，为了您更好的体验，请您先下载数据库文件(31.94MB)。", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "暂不下载", style: .Cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "立即下载", style: .Default, handler: { (_) in
                let statusBarView = JDStatusBarNotification.showWithStatus("正在下载诗词数据", styleName: JDStatusBarStyleDark)
                let path = "\(DocumentPath)/poem.zip"
                Alamofire.download(.GET, "http://classicpoem.oss-cn-shanghai.aliyuncs.com/poem.zip", parameters: nil, destination: { (_, _) -> NSURL in
                    if NSFileManager.defaultManager().fileExistsAtPath(path) {
                        try! NSFileManager.defaultManager().removeItemAtPath(path)
                    }
                    return NSURL(fileURLWithPath: path)
                }).progress({ (s, d, f) in
                    dispatch_async(dispatch_get_main_queue(), { 
                        statusBarView.textLabel.text = String(format: "正在下载诗词数据%.1f%%", CGFloat(d)/CGFloat(f)*100)
                    })
                }).response(completionHandler: { (_, _, _, error) in
                    if error == nil {
                        statusBarView.textLabel.text = "下载成功"
                        SSZipArchive.unzipFileAtPath(path, toDestination: DocumentPath)
                        try! NSFileManager.defaultManager().removeItemAtPath(path)
                        LocalDBExist = DataManager.manager.connect()
                    } else {
                        statusBarView.textLabel.text = "下载失败"
                    }
                    JDStatusBarNotification.dismissAfter(1.0)
                })
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    var isLoading = false
    func loadPoemData(id : Int = 0) {
        if isLoading {
            return
        }
        isLoading = true
        Recommend.GetRec(id) { (rec, err) in
            self.headerView.indicatorView.stopAnimation()
            self.isLoading = false
            self.needLoading = false
            if err != nil {
                self.headerView.titleLabel.text = "错"
                self.headerView.descLabel.text = "加载推荐失败，请重试..."
                return
            }
            self.headerView.data = rec
            self.poems = rec?.poems ?? []
            self.tableView.reloadData()
        }
    }
    
    var needLoading = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if tableView.contentOffset.y + 64 < 0 {
            if tableView.contentOffset.y + 64 < -100 && !self.needLoading{
                headerView.indicatorView.startAnimation()
                self.needLoading = true
            }
            headerView.frame = CGRect(x: 0, y: tableView.contentOffset.y + 64 , width: headerView.frame.size.width, height: 160 - 64 - tableView.contentOffset.y)
        } else {
            if self.needLoading {
                loadPoemData()
            }
            headerView.frame = CGRect(x: 0, y:0, width: headerView.frame.size.width, height: 160)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! RecommadCell
        cell.data = poems[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailVC = segue.destinationViewController as? PoemDetailViewController {
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            let data = poems[indexPath.row]
            detailVC.poemId = data.id
        }
    }
    
}

class RecommandHeaderView : UIView {
    
    @IBOutlet var backgroundImageView:UIImageView!
    
    @IBOutlet var titleLabel:UILabel!
    
    @IBOutlet var descLabel:UILabel!
    
    @IBOutlet var timeLabel:UILabel!
    
    @IBOutlet var indicatorView:NVActivityIndicatorView!
    
    override func awakeFromNib() {
        titleLabel.font = UIFont(name: UserFont, size: 64)
        descLabel.font = UIFont(name: UserFont, size: 17)
        descLabel.adjustsFontSizeToFitWidth = true
        timeLabel.font = UIFont(name: UserFont, size: 15)
    }
    
    var data:Recommend! {
        didSet {
            if data == nil {
              return
            }
            titleLabel.text = data.title
            descLabel.text = data.desc
            timeLabel.text = data.time
        }
    }
    
}

class RecommadCell: AnimatableTableViewCell {
    
    @IBOutlet var headImageView: UIImageView!
    
    @IBOutlet var authorLabel: UILabel!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var descLabel: UILabel!
    
    override func awakeFromNib() {
        titleLabel.font = UIFont(name: UserFont, size: 18)
        descLabel.font = UIFont(name: UserFont, size: 15)
        authorLabel.font = UIFont(name: UserFont, size: 14)
    }
    
    var data:Poem! {
        didSet {
            if data == nil {
                return
            }
            let url = data.poet?.name.iconURL() ?? ""
            headImageView.af_setImageWithURL(NSURL(string:url)!, placeholderImage: UIImage(named:"defaulticon"))
            titleLabel.text = data.title
            descLabel.text = data.content
            authorLabel.text = data.poet?.name
        }
    }
}
