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
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserFontChangeNotif"), object: nil, queue: OperationQueue.main) { (_) in
            self.tableView.reloadData()
        }
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
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
            let alertController = UIAlertController(title: "下载诗词数据", message: "检测到诗词数据库文件尚未下载，为了您更好的体验，请您先下载数据库文件(31.94MB)。", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "暂不下载", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "立即下载", style: .default, handler: { (_) in
                let statusBarView = JDStatusBarNotification.show(withStatus: "正在下载诗词数据", styleName: JDStatusBarStyleDark)
                let path = "\(DocumentPath)/poem.zip"
                Alamofire.download("http://classicpoem.oss-cn-shanghai.aliyuncs.com/poem.zip", to: { (_, _) in
                    if FileManager.default.fileExists(atPath: path) {
                        try! FileManager.default.removeItem(atPath: path)
                    }
                    return (URL(fileURLWithPath: path), [.removePreviousFile, .createIntermediateDirectories])
                }).downloadProgress(closure: { (p) in
                    DispatchQueue.main.async(execute: {
                        statusBarView?.textLabel.text = String(format: "正在下载诗词数据%.1f%%", p.fractionCompleted*100)
                    })
                }).response(completionHandler: { (res) in
                    if res.error != nil {
                        statusBarView?.textLabel.text = "下载失败"
                    } else {
                        statusBarView?.textLabel.text = "下载成功"
                        SSZipArchive.unzipFile(atPath: path, toDestination: DocumentPath)
                        try! FileManager.default.removeItem(atPath: path)
                        LocalDBExist = DataManager.manager.connect()
                    }
                    JDStatusBarNotification.dismiss(after: 1.0)
                })
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    var isLoading = false
    func loadPoemData(_ id : Int = 0) {
        if isLoading {
            return
        }
        isLoading = true
        Recommend.GetRec(id) { (rec, err) in
            self.headerView.indicatorView.stopAnimating()
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecommadCell
        cell.data = poems[(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? PoemDetailViewController {
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
            let data = poems[(indexPath as NSIndexPath).row]
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
        titleLabel.font = UIFont.userFont(size:64)
        descLabel.font = UIFont.userFont(size:17)
        descLabel.adjustsFontSizeToFitWidth = true
        timeLabel.font = UIFont.userFont(size:15)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserFontChangeNotif"), object: nil, queue: OperationQueue.main) { (_) in
            self.titleLabel.font = UIFont.userFont(size:64)
            self.descLabel.font = UIFont.userFont(size:17)
            self.descLabel.adjustsFontSizeToFitWidth = true
            self.timeLabel.font = UIFont.userFont(size:15)
        }
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
        titleLabel.font = UIFont.userFont(size:18)
        descLabel.font = UIFont.userFont(size:15)
        authorLabel.font = UIFont.userFont(size:14)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserFontChangeNotif"), object: nil, queue: OperationQueue.main) { (_) in
            self.titleLabel.font = UIFont.userFont(size:18)
            self.descLabel.font = UIFont.userFont(size:15)
            self.authorLabel.font = UIFont.userFont(size:14)
        }
    }
    
    var data:Poem! {
        didSet {
            if data == nil {
                return
            }
            let url = data.poet?.name.iconURL() ?? ""
            headImageView.af_setImage(withURL:URL(string:url)!, placeholderImage: UIImage(named:"defaulticon"))
            titleLabel.text = data.title
            descLabel.text = data.content
            authorLabel.text = data.poet?.name
        }
    }
}
