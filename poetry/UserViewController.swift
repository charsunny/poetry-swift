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
        NSNotificationCenter.defaultCenter().addObserverForName("LoginSuccess", object: nil, queue: NSOperationQueue.mainQueue()) { (_) in
            self.showUserInfo()
        }
        headerView.backgroundColor = UIColor.flatRedColor()
        showUserInfo()
        loadFeeds()
    }
    
    func showUserInfo() {
        var userinfo:User? = self.user
        if userinfo == nil {
            userinfo = User.LoginUser
        }
        if let user = userinfo  {
            avatarImageView.af_setImageWithURL(NSURL(string: user.avatar) ?? NSURL(), placeholderImage: UIImage(named: "defaulticon"))
            nameLabel.text = user.nick
            likeCountLabel.text = "\(user.likeCount)"
            favCountLabel.text = "\(user.columnCount)"
            followCountLabel.text = "\(user.followCount)"
            followeeCountLabel.text = "\(user.followeeCount)"
        }
    }
    
    var hasMore = false
    var isLoading = false
    var page = -1
    func loadFeeds(page:Int = 0) {
        if isLoading {
            return
        }
        isLoading = true
        Feed.GetUserFeeds(0) { (list, error) in
            self.isLoading = false
            if page != self.page + 1 {
                return
            }
            if error == nil {
                if list.count > 0 {
                    self.feedList.appendContentsOf(list)
                    self.tableView.reloadData()
                } else {
                    self.hasMore = false
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.hidden = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.hidden = false
    }
    

    override func viewDidLayoutSubviews() {
        let offset = tableView.contentOffset
        headerView.frame = CGRect(x: 0, y: offset.y, width: headerView.frame.width, height: 230 - offset.y)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if hasMore && scrollView.contentOffset.y > 100 && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            self.loadFeeds(self.page + 1)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return feedList.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 424
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! PoemCardCell
        cell.feed = feedList[indexPath.section]
        return cell
    }
    
}

extension UserViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string:"暂无分享内容", attributes: TextAttributes().foregroundColor(UIColor.darkGrayColor()).font(UIFont.userFontWithSize(15)).alignment(.Center))
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "theme4")?.af_imageScaledToSize(CGSize(width: 120, height: 120)).af_imageWithRoundedCornerRadius(60)
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return 0
    }
}
