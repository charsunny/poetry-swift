//
//  PoemCommentViewController.swift
//  poetry
//
//  Created by sunsing on 8/29/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import SlackTextViewController

class PoemCommentViewController: SLKTextViewController, UIPopoverPresentationControllerDelegate {
    
    var poem:Poem?
    
    var comments:[Comment] = []
    
    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Plain
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.delaysContentTouches = false
        self.tableView?.estimatedRowHeight = 80
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.registerNib(UINib(nibName: "PoemSummaryCell", bundle: nil), forCellReuseIdentifier: "hcell")
        self.tableView?.registerNib(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.textInputbar.textView.placeholder = "请输入评论内容"
        self.textInputbar.rightButton.setTitle("评论", forState: .Normal)
        self.inverted = false
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            if comments.count == 0 {
                return nil
            }
            return "所有评论(\(comments.count))"
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 10
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 1 {
//            let cell = tableView.cellForRowAtIndexPath(indexPath)
//            self.performSegueWithIdentifier("popmenu", sender: cell)
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (_) in
                
            }))
            alertController.addAction(UIAlertAction(title: "回复", style: .Default, handler: { (_) in
                
            }))
            alertController.addAction(UIAlertAction(title: "复制", style: .Default, handler: { (_) in
                
            }))
            alertController.addAction(UIAlertAction(title: "分享", style: .Default, handler: { (_) in
                
            }))
            alertController.addAction(UIAlertAction(title: "举报", style: .Default, handler: { (_) in
                
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("hcell", forIndexPath: indexPath) as! PoemSummaryCell
            cell.data = self.poem
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CommentCell
            cell.contentTextLabel.text = "abcdf"
            cell.commentTextLabel?.text = "xxxasds\nsdfjklsfjskljfalksdjaslkd\nsdakdjaskldjlsdj"
            return cell
        }
    }
    
    override func didPressRightButton(sender: AnyObject?) {
        if let text = textInputbar.textView.text {
            debugPrint(text)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destinationViewController as? CommentMenuViewController {
            if let cell = sender as? UITableViewCell {
                vc.popoverPresentationController?.backgroundColor = UIColor.whiteColor()
                vc.popoverPresentationController?.sourceRect = cell.bounds
                vc.popoverPresentationController?.sourceView = cell
                vc.popoverPresentationController?.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

}
