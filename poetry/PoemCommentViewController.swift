//
//  PoemCommentViewController.swift
//  poetry
//
//  Created by sunsing on 8/29/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import SlackTextViewController
import StatusProvider

enum CommentType {
    case poem
    case feed
    case column
}

class PoemCommentViewController: SLKTextViewController, UIPopoverPresentationControllerDelegate {
    
    var commentType:CommentType = .poem
    
    var poem:Poem?
    
    var feed:Feed?
    
    var column:Column?
    
    var comments:[Comment] = []
    
    var page:Int = -1
    
    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        return .plain
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.delaysContentTouches = false
        tableView?.tableFooterView = UIView()
        self.tableView?.estimatedRowHeight = 80
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.register(UINib(nibName: "PoemSummaryCell", bundle: nil), forCellReuseIdentifier: "hcell")
        self.tableView?.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.textInputbar.textView.placeholder = "请输入评论内容"
        self.textInputbar.rightButton.setTitle("评论", for: UIControlState())
        self.isInverted = false
        switch commentType {
        case .poem:
            self.title = poem?.title ?? ""
        case .feed:
            self.title = "评论"
        default:
            self.title = column?.title ?? ""
        }
        self.show(statusType: .loading)
        loadComments(page: 0)
    }
    
    var hasMore = true
    func loadComments(page:Int) {
        let finish : ([Comment], Error?) -> Void = { list, err in
            self.hide(statusType: .loading)
            if err == nil {
                if page == self.page + 1 {
                    if list.count > 0 {
                        self.page = page
                        self.comments.append(contentsOf: list)
                        self.tableView?.reloadData()
                    } else {
                        self.hasMore = false
                        if self.comments.count == 0 {
                            self.show(statusType: StatusProviderType.empty(action: {
                                self.textInputbar.textView.becomeFirstResponder()
                            }))
                            self.view.bringSubview(toFront: self.textInputbar)
                        }
                    }
                }
            }
        }
        switch commentType {
        case .poem:
            poem?.getComments(page: page, finish: finish)
        case .feed:
            feed?.getComments(page: page, finish: finish)
        default:
            column?.getComments(page: page, finish: finish)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if hasMore && scrollView.contentOffset.y > 100 && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            self.loadComments(page: self.page + 1)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        /*let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            
        }))
        alertController.addAction(UIAlertAction(title: "回复", style: .default, handler: { (_) in
            
        }))
        alertController.addAction(UIAlertAction(title: "复制", style: .default, handler: { (_) in
            
        }))
        alertController.addAction(UIAlertAction(title: "分享", style: .default, handler: { (_) in
            
        }))
        alertController.addAction(UIAlertAction(title: "举报", style: .default, handler: { (_) in
            
        }))
        self.present(alertController, animated: true, completion: nil)*/
    }
    
    var replyComment : Comment?
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
        cell.comment = comments[indexPath.row]
        cell.replyCommentAction = {
            self.textInputbar.textView.placeholder = "回复@\($0.user!.nick):"
            self.replyComment = $0
            DispatchQueue.main.async {
                self.textInputbar.textView.becomeFirstResponder()
            }
        }
        cell.showUserAction = {
            if let user = $0 {
                if let userVC = UIStoryboard(name: "User", bundle: nil).instantiateViewController(withIdentifier: "uservc") as? UserViewController {
                    userVC.user = user
                    self.navigationController?.pushViewController(userVC, animated: true)
                }
            }
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    override func didPressRightButton(_ sender: Any?) {
        if let text = textInputbar.textView.text {
            var type = 1
            var id = 0
            switch commentType {
            case .poem:
                type = 1
                id = poem?.id ?? 0
            case .feed:
                type = 2
                id = feed?.id ?? 0
            default:
                id = column?.id ?? 0
                type = 3
            }
            HUD.show()
            User.LoginUser?.addComment(type: type, id: id, cid: replyComment?.id ?? 0, content: text, finish: { (comment, error) in
                HUD.dismiss()
                if let comment = comment {
                    HUD.flash(.success("评论成功"), delay: 3.0)
                    comment.comment = self.replyComment
                    self.comments.insert(comment, at: 0)
                    self.hide(statusType: .empty(action:nil))
                    self.tableView?.reloadData()
                    self.textInputbar.textView.text = nil
                    self.textInputbar.textView.resignFirstResponder()
                } else {
                    HUD.flash(.error(error?.localizedDescription ?? ""), delay: 3.0)
                }
            })
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? CommentMenuViewController {
            if let cell = sender as? UITableViewCell {
                vc.popoverPresentationController?.backgroundColor = UIColor.white
                vc.popoverPresentationController?.sourceRect = cell.bounds
                vc.popoverPresentationController?.sourceView = cell
                vc.popoverPresentationController?.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

}

extension PoemCommentViewController : StatusProvider {
    var emptyView: EmptyStatusDisplaying?{
        let image = UIImage(named: "theme4")?.af_imageScaled(to:CGSize(width: 120, height: 120)).af_imageRounded(withCornerRadius:60)
        return EmptyStatusView(title: "没有评论", caption: "暂时没有诗词评论", image: image, actionTitle: "添加评论")
    }
}
