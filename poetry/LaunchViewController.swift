//
//  LaunchViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/8/27.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController, TencentSessionDelegate {

    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var centerLayout: NSLayoutConstraint!
    
    @IBOutlet weak var firstLineLabel: UILabel!
    
    @IBOutlet weak var secondLineLabel: UILabel!
    
    @IBOutlet weak var titleImageView: UIImageView!
    
    @IBOutlet weak var enterButton: UIButton!
    
    @IBOutlet weak var weiboButton: UIButton!
    
    @IBOutlet weak var qqButton: UIButton!
    
    @IBOutlet weak var tipLabel: UILabel!
    
    var qqOAuth : TencentOAuth!
    
    var openId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.qqButton.isHidden = true
        self.weiboButton.isHidden = true
        indicatorView.isHidden = true
        firstLineLabel.font = UIFont.userFont(size:24)
        secondLineLabel.font = UIFont.userFont(size:24)
        enterButton.isHidden = true
        qqOAuth = TencentOAuth(appId: "1105650150", andDelegate: self)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "LoginSuccess"), object: nil, queue: OperationQueue.main) { (_) in
            self.perform(#selector(LaunchViewController.enterMainPage(_:)), with: nil, afterDelay: 1)
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
            })
        }) { (_) in
            self.centerLayout.constant = 100
            self.enterButton.isHidden = false
            if User.Token == nil {
                self.qqButton.isHidden = false
                self.weiboButton.isHidden = false
                self.tipLabel.isHidden = false
            } else {
                self.indicatorView.isHidden = false
                self.indicatorView.startAnimating()
                User.GetUserInfo({ (u, error) in
                    self.indicatorView.isHidden = true
                    if error != nil {
                        self.qqButton.isHidden = false
                        self.weiboButton.isHidden = false
                        self.tipLabel.isHidden = false
                       // HUD.flash(.labeledError(title: "加载失败", subtitle: "请重新登录"), delay: 1.0)
                    } else {
                        if UIApplication.shared.keyWindow?.rootViewController == self {
                            self.perform(#selector(LaunchViewController.enterMainPage(_:)), with: nil, afterDelay: 1)
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func enterMainPage(_ sender: AnyObject?) {
        //HUD.hide()
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }

    @IBAction func loginWithWeibo(_ sender: AnyObject) {
        let request = WBAuthorizeRequest()
        request.redirectURI = "http://classicpoem.cn"
        request.scope = "all"
        request.userInfo = ["SSO_From":"LaunchViewController"]
        WeiboSDK.send(request)
    }
    
    @IBAction func loginWithQQ(_ sender: AnyObject) {
        qqOAuth.authorize([kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO], inSafari: false)
    }
   
    func tencentDidLogin() {
        debugPrint(qqOAuth.appId)
        if qqOAuth.getUserInfo() {
            self.openId = qqOAuth.openId
            //HUD.show(.progress)
        } else {
            //HUD.flash(.labeledError(title: "拉取授权信息失败", subtitle:""), delay: 1)
        }
    }
    
    func getUserInfoResponse(_ response: APIResponse!) {
        guard let openId = self.openId else {return}
        guard let dict = response.jsonResponse else {return}
        Login.LoginWithSNS(dict["nickname"] as? String ?? "", gender: 1, avatar: (dict["figureurl_qq_2"] as? String ?? dict["figureurl_2"] as? String  ?? ""), userId: openId, snsType: 2, finish: { (login, err) in
            //HUD.hide()
            if err != nil {
               // HUD.flash(.labeledError(title: "登录失败", subtitle: String.ErrorString(err!)), delay: 1)
            } 
        })
    }
    
    func tencentDidNotLogin(_ cancelled: Bool) {
        
    }
    
    func tencentDidNotNetWork() {
        
    }
}
