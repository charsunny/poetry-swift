//
//  SettingViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/8/26.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import Alamofire
import SSZipArchive
import JDStatusBarNotification
import AlamofireImage
import SVProgressHUD


class SettingViewController: UITableViewController {

    @IBOutlet weak var fontChooseCell: UITableViewCell!
    
    @IBOutlet weak var bgMusicCell: UITableViewCell!
    
    @IBOutlet weak var dbzcell: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let switcher = UISwitch()
        switcher.onTintColor = UIColor.flatRedColorDark()
        switcher.addTarget(self, action: #selector(switchBgMusic(_:)), for: .valueChanged)
        switcher.isOn = !User.BgMusicOff
        bgMusicCell.accessoryView = switcher
        if User.LoginUser == nil {
            tableView.tableFooterView = nil
        }
        dbzcell.detailTextLabel?.text = (LocalDBExist ? "已下载" : "未下载")
    }
    
    func switchBgMusic(_ swicther:UISwitch) {
        User.BgMusicOff = !User.BgMusicOff
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let font = CustomFonts.filter({$0.1 == User.Font}).first?.0 {
            fontChooseCell.detailTextLabel?.text = font
        } else {
            fontChooseCell.detailTextLabel?.text = ""
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 2 && indexPath.section == 0 {
            if !LocalDBExist {
                let alertController = UIAlertController(title: "下载诗词数据", message: "检测到诗词数据库文件尚未下载，为了您更好的体验，推荐您下载数据库文件(31.94MB)。", preferredStyle: .alert)
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
        if indexPath.row == 1 && indexPath.section == 1 {
            if let chat = RCConversationViewController(conversationType: .ConversationType_PRIVATE, targetId: "1") {
                chat.title = "意见反馈"
                chat.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(chat, animated: true)
            }
        }
    }
    
    @IBAction func onLogout(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "退出登录", message: "确定要退出登录吗？", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
            RCIM.shared().logout()
            User.LoginUser = nil
            User.Token = nil
            self.tableView.tableFooterView = nil
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
