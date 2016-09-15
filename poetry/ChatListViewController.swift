//
//  CreatorListViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/23.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import IBAnimatable
import TextAttributes
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ChatListViewController: RCConversationListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //设置需要显示哪些类型的会话
        self.setDisplayConversationTypes([RCConversationType.ConversationType_PRIVATE.rawValue,
            RCConversationType.ConversationType_DISCUSSION.rawValue,
            RCConversationType.ConversationType_CHATROOM.rawValue,
            RCConversationType.ConversationType_GROUP.rawValue,
            RCConversationType.ConversationType_APPSERVICE.rawValue,
            RCConversationType.ConversationType_SYSTEM.rawValue])
        //设置需要将哪些类型的会话在会话列表中聚合显示
        self.setCollectionConversationType([RCConversationType.ConversationType_DISCUSSION.rawValue,
            RCConversationType.ConversationType_GROUP.rawValue])
        self.conversationListTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if RCIM.shared().getConnectionStatus() == RCConnectionStatus.ConnectionStatus_Unconnected {
            if User.LoginUser?.rongToken.characters.count > 0 {
                RCIM.shared().connect(withToken: User.LoginUser?.rongToken ?? "",
                    success: { (userId) -> Void in
                        print("登陆成功。当前登录的用户ID：\(userId)")
                    }, error: { (status) -> Void in
                        print("登陆的错误码为:\(status.rawValue)")
                    }, tokenIncorrect: {
                        print("token错误")
                })
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

