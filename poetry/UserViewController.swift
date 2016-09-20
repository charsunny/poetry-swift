//
//  UserViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/10.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import AlamofireImage
import DZNEmptyDataSet
import TextAttributes
import SVProgressHUD

class UserViewController: UITableViewController {
    
    var user : User?
    
    var feedList : [Feed] = []

    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    
    @IBOutlet weak var favCountLabel: UILabel!
    
    @IBOutlet weak var followCountLabel: UILabel!
    
    @IBOutlet weak var followeeCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "PoemExploreCell", bundle:nil), forCellReuseIdentifier: "cell")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "LoginSuccess"), object: nil, queue: OperationQueue.main) { (_) in
            self.showUserInfo()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserFontChangeNotif"), object: nil, queue: OperationQueue.main) { (_) in
            self.tableView.reloadData()
        }
        tableView.estimatedRowHeight = 420
        tableView.rowHeight = UITableViewAutomaticDimension
        headerView.backgroundColor = UIColor.flatRed()
        showUserInfo()
        SVProgressHUD.show()
        loadFeeds()
    }
    
    func showUserInfo() {
        var userinfo:User? = self.user
        if userinfo == nil {
            userinfo = User.LoginUser
        }
        if let user = userinfo  {
            avatarImageView.af_setImage(withURL:URL(string: user.avatar) ?? URL(string:"http://127.0.0.1/")!, placeholderImage: UIImage(named: "defaulticon"))
            nameLabel.text = user.nick
            likeCountLabel.text = "\(user.likeCount)"
            favCountLabel.text = "\(user.columnCount)"
            followCountLabel.text = "\(user.followCount)"
            followeeCountLabel.text = "\(user.followeeCount)"
        }
    }
    
    @IBAction func refresFeeds(_ sender: AnyObject) {
        Feed.GetFeedsAfter(feedList.first?.id ?? -1) { (list, error) in
            self.refreshControl?.endRefreshing()
            if error == nil {
                if list.count > 0 {
                    self.feedList.insert(contentsOf: list, at: 0)
                    self.tableView.reloadData()
                }
            } else {
                HUD.flash(.error(error!.localizedDescription), delay: 1.0)
            }
        }
    }
    
    var hasMore = false
    var isLoading = false
    var page = -1
    func loadFeeds(_ page:Int = 0) {
        if isLoading {
            return
        }
        isLoading = true
        Feed.GetUserFeeds(0) { (list, error) in
            self.isLoading = false
            SVProgressHUD.dismiss()
            if page != self.page + 1 {
                return
            }
            if error == nil {
                if list.count > 0 {
                    self.feedList.append(contentsOf: list)
                    self.tableView.reloadData()
                } else {
                    self.hasMore = false
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    

    override func viewDidLayoutSubviews() {
        let offset = tableView.contentOffset
        headerView.frame = CGRect(x: 0, y: offset.y, width: headerView.frame.width, height: 230 - offset.y)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if hasMore && scrollView.contentOffset.y > 100 && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            self.loadFeeds(self.page + 1)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return feedList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PoemExploreCell
        cell.viewController = self
        cell.feed = feedList[(indexPath as NSIndexPath).section]
        return cell
    }
    
}

extension UserViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string:"暂无分享内容", attributes: TextAttributes().foregroundColor(UIColor.darkGray).font(UIFont.userFont(size:15)).alignment(.center))
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "theme4")?.af_imageScaled(to:CGSize(width: 120, height: 120)).af_imageRounded(withCornerRadius:60)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 40
    }
}
