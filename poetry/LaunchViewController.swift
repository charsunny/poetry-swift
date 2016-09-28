//
//  LaunchViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/8/27.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import SVProgressHUD

class LaunchViewController: UIViewController, TencentSessionDelegate, WXApiDelegate {
    
    var userInfo:NSDictionary?

    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var centerLayout: NSLayoutConstraint!
    
    @IBOutlet weak var firstLineLabel: UILabel!
    
    @IBOutlet weak var secondLineLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var titleImageView: UIImageView!
    
    @IBOutlet weak var enterButton: UIButton!
    
    @IBOutlet weak var weiboButton: UIButton!
    
    @IBOutlet weak var wechatButton: UIButton!
    
    @IBOutlet weak var qqButton: UIButton!
    
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    var timer:Timer!
    
    var leftTime = 5
    
    var qqOAuth : TencentOAuth!
    
    var openId: String?
    
    
    var content:String? {
        set {
            UserDefaults(suiteName: "group.com.charsunny.poetry")?.set(newValue, forKey: "group.com.charsunny.poetry.wc")
        }
        get {
            return UserDefaults(suiteName: "group.com.charsunny.poetry")?.string(forKey: "group.com.charsunny.poetry.wc")
        }
    }
    
    var subtitle:String? {
        set {
            UserDefaults(suiteName: "group.com.charsunny.poetry")?.set(newValue, forKey: "group.com.charsunny.poetry.wdesc")
        }
        get {
            return UserDefaults(suiteName: "group.com.charsunny.poetry")?.string(forKey: "group.com.charsunny.poetry.wdesc")
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
        self.qqButton.isHidden = true
        self.weiboButton.isHidden = true
        self.wechatButton.isHidden = true
        self.timerLabel.isHidden = true
        indicatorView.isHidden = true
        authorLabel.alpha = 0
        firstLineLabel.font = UIFont.userFont(size:24)
        secondLineLabel.font = UIFont.userFont(size:24)
        authorLabel.font = UIFont.userFont(size: 15)
        enterButton.isHidden = true
        qqOAuth = TencentOAuth(appId: "1105650150", andDelegate: self)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "LoginSuccess"), object: nil, queue: OperationQueue.main) { (_) in
            self.perform(#selector(LaunchViewController.enterMainPage(_:)), with: nil, afterDelay: 1)
        }
        Recommend.GetTodayRec { (rec, _) in
            if let rec = rec {
                self.content = rec.content
                self.subtitle =  (rec.poem?.poet?.name ?? "无名氏") + "◦" + (rec.poem?.title ?? "无题")
                self.poemId = rec.poem?.id ?? 0
                self.poetId = rec.poem?.poet?.id ?? 0
            }
        }
        if self.content != nil {
            let cmps = self.content?.components(separatedBy: "\n")
            self.firstLineLabel.text = cmps?.last?.trimmingCharacters(in: CharacterSet(charactersIn: "，。 \n\r"))
            self.secondLineLabel.text = cmps?.first?.trimmingCharacters(in: CharacterSet(charactersIn: "，。 \n\r"))
        }
        if self.subtitle != nil {
            self.authorLabel.text = self.subtitle
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.5, options: .layoutSubviews, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3, animations: {
                self.titleImageView.center = CGPoint(x: self.view.frame.width/2 + 100, y: self.view.frame.height/2)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.3, relativeDuration: 0.7, animations: {
                self.firstLineLabel.alpha = 1.0
                self.secondLineLabel.alpha = 1.0
                self.authorLabel.alpha = 1.0
            })
        }) { (_) in
            self.centerLayout.constant = 100
            self.enterButton.isHidden = false
            if User.Token == nil {
                self.qqButton.isHidden = false
                self.weiboButton.isHidden = false
                self.tipLabel.isHidden = false
                if WXApi.isWXAppInstalled() {
                    self.wechatButton.isHidden = false
                }
                self.timerLabel.isHidden = false
                self.leftTime = 5
                self.timerLabel.text = "\(self.leftTime)s"
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(LaunchViewController.onTimer), userInfo: nil, repeats: true)
            } else {
                self.indicatorView.isHidden = false
                self.indicatorView.startAnimating()
                User.GetUserInfo { (u, error) in
                    self.indicatorView.isHidden = true
                    if error != nil {
                        self.qqButton.isHidden = false
                        self.weiboButton.isHidden = false
                        if WXApi.isWXAppInstalled() {
                            self.wechatButton.isHidden = false
                        }
                        self.tipLabel.isHidden = false
                        SVProgressHUD.showError(withStatus: "加载失败，请重新登录")
                        SVProgressHUD.dismiss(withDelay: 1)                    } else {
                        if UIApplication.shared.keyWindow?.rootViewController == self {
                            self.leftTime = 5
                            self.timerLabel.isHidden = false
                            self.timerLabel.text = "\(self.leftTime)s"
                            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(LaunchViewController.onTimer), userInfo: nil, repeats: true)
                        }
                    }
                }
            }
        }
    }
    
    func onTimer() {
        self.leftTime = self.leftTime - 1
        if leftTime <= 0 {
            timer.invalidate()
            self.enterMainPage(nil)
        } else {
            self.timerLabel.text = "\(self.leftTime)s"
        }
    }
    
    @IBAction func enterMainPage(_ sender: AnyObject?) {
        //HUD.hide()
        (UIApplication.shared.delegate as? AppDelegate)?.window = UIApplication.shared.windows.first
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }

    @IBAction func loginWithWeibo(_ sender: AnyObject) {
        timer?.invalidate()
        let request = WBAuthorizeRequest()
        request.redirectURI = "http://classicpoem.cn"
        request.scope = "all"
        request.userInfo = ["SSO_From":"LaunchViewController"]
        WeiboSDK.send(request)
    }
    
    @IBAction func loginWithWechat(_ sender: AnyObject) {
        timer?.invalidate()
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "xxx"
        //req.openID = "wxb44969eb6f18907d"
        WXApi.sendAuthReq(req, viewController: self, delegate: self)
    }
    
    @IBAction func loginWithQQ(_ sender: AnyObject) {
        timer?.invalidate()
        qqOAuth.authorize([kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO], inSafari: false)
    }
   
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
