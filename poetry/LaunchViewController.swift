//
//  LaunchViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/8/27.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import PKHUD

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.qqButton.hidden = true
        self.weiboButton.hidden = true
        indicatorView.hidden = true
        firstLineLabel.font = UIFont.userFontWithSize(24)
        secondLineLabel.font = UIFont.userFontWithSize(24)
        enterButton.hidden = true
        qqOAuth = TencentOAuth(appId: "1105650150", andDelegate: self)
        NSNotificationCenter.defaultCenter().addObserverForName("LoginSuccess", object: nil, queue: NSOperationQueue.mainQueue()) { (_) in
            self.performSelector(#selector(LaunchViewController.enterMainPage(_:)), withObject: nil, afterDelay: 1)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateKeyframesWithDuration(2.0, delay: 0.5, options: .LayoutSubviews, animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.3, animations: {
                self.titleImageView.center = CGPoint(x: self.view.frame.width/2 + 100, y: self.view.frame.height/2)
            })
            UIView.addKeyframeWithRelativeStartTime(0.3, relativeDuration: 0.7, animations: {
                self.firstLineLabel.alpha = 1.0
                self.secondLineLabel.alpha = 1.0
            })
        }) { (_) in
            self.centerLayout.constant = 100
            self.enterButton.hidden = false
            if User.Token == nil {
                self.qqButton.hidden = false
                self.weiboButton.hidden = false
                self.tipLabel.hidden = false
            } else {
                self.indicatorView.hidden = false
                self.indicatorView.startAnimating()
                User.GetUserInfo({ (u, error) in
                    self.indicatorView.hidden = true
                    if error != nil {
                        self.qqButton.hidden = false
                        self.weiboButton.hidden = false
                        self.tipLabel.hidden = false
                        HUD.flash(.LabeledError(title: "加载失败", subtitle: "请重新登录"), delay: 1.0)
                    } else {
                        self.performSelector(#selector(LaunchViewController.enterMainPage(_:)), withObject: nil, afterDelay: 1)
                    }
                })
            }
        }
    }
    
    @IBAction func enterMainPage(sender: AnyObject?) {
        HUD.hide()
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        UIApplication.sharedApplication().keyWindow?.rootViewController = mainVC
    }

    @IBAction func loginWithWeibo(sender: AnyObject) {
        let request = WBAuthorizeRequest()
        request.redirectURI = "http://classicpoem.cn"
        request.scope = "all"
        request.userInfo = ["SSO_From":"LaunchViewController"]
        WeiboSDK.sendRequest(request)
    }
    
    @IBAction func loginWithQQ(sender: AnyObject) {
        qqOAuth.authorize([kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO], inSafari: false)
    }
   
    func tencentDidLogin() {
        debugPrint(qqOAuth.appId)
    }
    
    func tencentDidNotLogin(cancelled: Bool) {
        
    }
    
    func tencentDidNotNetWork() {
        
    }
}
