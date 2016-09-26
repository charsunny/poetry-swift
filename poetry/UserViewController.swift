//
//  UserViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/10.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import AlamofireImage
import StatusProvider
import TextAttributes
import SVProgressHUD

class UserViewController: UITableViewController {
    
    var user : User?
    
    var feedList : [Feed] = []

    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var settingButton: UIButton!
    
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
        self.show(statusType: .loading)
        if let user = user {
            loadFeeds(0, uid: user.id)
        } else {
            loadFeeds()
        }
        if self == self.navigationController?.viewControllers.first {
            self.backButton.isHidden = true
            self.settingButton.isHidden = false
        } else {
            self.backButton.isHidden = false
            self.settingButton.isHidden = true
        }
    }
    
    @IBAction func onNavBack(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
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
            self.hide(statusType: .loading)
            if error == nil {
                if list.count > 0 {
                    self.feedList.insert(contentsOf: list, at: 0)
                    self.tableView.reloadData()
                } else {
                    self.show(statusType: .empty(action:nil))
                }
            } else {
                HUD.flash(.error(error!.localizedDescription), delay: 1.0)
            }
        }
    }
    
    var hasMore = false
    var isLoading = false
    var page = -1
    func loadFeeds(_ page:Int = 0, uid:Int = 0) {
        if isLoading {
            return
        }
        isLoading = true
        Feed.GetUserFeeds(page, uid:uid) { (list, error) in
            self.isLoading = false
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
        cell.feed = feedList[(indexPath as NSIndexPath).section]
        cell.showPoemAction = {
            if let poemVC = UIStoryboard(name:"Recommend", bundle: nil).instantiateViewController(withIdentifier: "poemvc") as? PoemDetailViewController {
                poemVC.poem = $0
                self.navigationController?.pushViewController(poemVC, animated: true)
            }
        }
        cell.showUserAction = {
            if let userVC = UIStoryboard(name:"User", bundle: nil).instantiateViewController(withIdentifier: "uservc") as? UserViewController {
                userVC.user = $0
                self.navigationController?.pushViewController(userVC, animated: true)
            }
        }
        cell.commentAction = {
            if let commentVC = UIStoryboard(name:"Recommend", bundle: nil).instantiateViewController(withIdentifier: "commentvc") as? PoemCommentViewController {
                commentVC.feed = $0
                commentVC.commentType = .feed
                self.navigationController?.pushViewController(commentVC, animated: true)
            }
        }
        cell.shareAction = {
            if let shareNavVC = UIStoryboard(name:"Explore", bundle: nil).instantiateViewController(withIdentifier: "sharenavvc") as? UINavigationController {
                if let shareVC = shareNavVC.viewControllers.first as? ExploreAddViewController {
                    shareVC.poem = $0.poem
                }
                self.present(shareNavVC, animated: true, completion: nil)
            }
        }
        return cell
    }
    
}

extension UserViewController: StatusProvider {
    
    var emptyView: EmptyStatusDisplaying?{
        let image = UIImage(named: "theme4")?.af_imageScaled(to:CGSize(width: 120, height: 120)).af_imageRounded(withCornerRadius:60)
        return EmptyStatusView(title: "没有分享", caption: "分享列表为空", image: image, actionTitle: nil)
    }
}
