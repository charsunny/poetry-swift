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
    
    var qqOAuth : TencentOAuth!
    
    var openId: String?
    
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
        qqOAuth = TencentOAuth(appId: "1105650150", andDelegate: self)
        tableView.register(UINib(nibName: "PoemExploreCell", bundle:nil), forCellReuseIdentifier: "cell")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "LoginSuccess"), object: nil, queue: OperationQueue.main) { (_) in
            self.show(statusType: .loading)
            self.loadFeeds()
            self.showUserInfo()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserFontChangeNotif"), object: nil, queue: OperationQueue.main) { (_) in
            self.tableView.reloadData()
        }
        //tableView.estimatedRowHeight = 420
        tableView.rowHeight = 420
        headerView.backgroundColor = UIColor.flatRed()
        if let user = user {
            self.show(statusType: .loading)
            loadFeeds(0, uid: user.id)
        } else {
            if User.LoginUser != nil {
                self.show(statusType: .loading)
                loadFeeds()
            } else {
                self.show(statusType: .empty(action: { 
                    
                }))
            }
        }
        if self == self.navigationController?.viewControllers.first {
            self.backButton.isHidden = true
            self.settingButton.isHidden = false
        } else {
            self.backButton.isHidden = false
            self.settingButton.isHidden = true
        }
    }
    
    @IBAction func onTapHeader(_ sender: AnyObject) {
        let logined = (User.LoginUser != nil)
        let alertController = UIAlertController(title: logined ? "更换头像" : "用户登录", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        if logined {
            alertController.addAction(UIAlertAction(title: "相册选择", style: .default, handler: { (_) in
                
            }))
            alertController.addAction(UIAlertAction(title: "拍摄照片", style: .default, handler: { (_) in
                
            }))
        } else {
            alertController.addAction(UIAlertAction(title: "微博登录", style: .default, handler: { (_) in
                let request = WBAuthorizeRequest()
                request.redirectURI = "http://classicpoem.cn"
                request.scope = "all"
                request.userInfo = ["SSO_From":"LaunchViewController"]
                WeiboSDK.send(request)
            }))
            alertController.addAction(UIAlertAction(title: "微信登录", style: .default, handler: { (_) in
                let req = SendAuthReq()
                req.scope = "snsapi_userinfo"
                req.state = "xxx"
                //req.openID = "wxb44969eb6f18907d"
                WXApi.sendAuthReq(req, viewController: self, delegate: nil)
            }))
            alertController.addAction(UIAlertAction(title: "QQ登录", style: .default, handler: { (_) in
                self.qqOAuth.authorize([kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO], inSafari: false)
            }))
        }
        self.present(alertController, animated: true, completion: nil)
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
            //followeeCountLabel.text = "\(user.followeeCount)"
        } else {
            feedList.removeAll()
            nameLabel.text = "尚未登录，点击登录"
            avatarImageView.image = UIImage(named: "defaulticon")
            likeCountLabel.text = "0"
            favCountLabel.text = "0"
            followCountLabel.text = "0"
            self.tableView.reloadData()
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
            self.hide(statusType: .loading)
            if page != self.page + 1 {
                return
            }
            if error == nil {
                if list.count > 0 {
                    self.feedList.append(contentsOf: list)
                    self.tableView.reloadData()
                } else {
                    self.hasMore = false
                    if self.feedList.count == 0 {
                        self.show(statusType: .empty(action:nil))
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        showUserInfo()
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if User.Token == nil && identifier != "showsetting" && user == nil {
            return false
        }
        return true
    }
}

extension UserViewController: StatusProvider {
    
    var emptyView: EmptyStatusDisplaying?{
        let image = UIImage(named: "theme4")?.af_imageScaled(to:CGSize(width: 100, height: 100)).af_imageRounded(withCornerRadius:50)
        return EmptyStatusView(title: "暂无分享", caption: "分享列表为空", image: image, actionTitle: nil)
    }
}

extension UserViewController: TencentSessionDelegate {
    func tencentDidLogin() {
        debugPrint(qqOAuth.appId)
        if qqOAuth.getUserInfo() {
            self.openId = qqOAuth.openId
            SVProgressHUD.showSuccess(withStatus: "授权成功")
            SVProgressHUD.dismiss(withDelay: 1)
        } else {
            SVProgressHUD.showError(withStatus: "拉取授权信息失败")
            SVProgressHUD.dismiss(withDelay: 1)
        }
    }
    
    func getUserInfoResponse(_ response: APIResponse!) {
        guard let openId = self.openId else {return}
        guard let dict = response.jsonResponse else {return}
        Login.LoginWithSNS(dict["nickname"] as? String ?? "", gender: 1, avatar: (dict["figureurl_qq_2"] as? String ?? dict["figureurl_2"] as? String  ?? ""), userId: openId, snsType: 2, finish: { (login, err) in
            if err != nil {
                SVProgressHUD.showError(withStatus: "登录失败")
                SVProgressHUD.dismiss(withDelay: 1)
            }
        })
    }
    
    func tencentDidNotLogin(_ cancelled: Bool) {
        
    }
    
    func tencentDidNotNetWork() {
        
    }
}
