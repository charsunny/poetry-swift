//
//  PoemExploreCell.swift
//  poetry
//
//  Created by Xi Sun on 16/9/2.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import TextAttributes

class PoemExploreCell: UITableViewCell {

    weak var viewController:UIViewController?
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userTimeLabel: UILabel!
    
    @IBOutlet weak var contentImageView: UIImageView!
    
    @IBOutlet weak var contentDescView: UIView!
    
    @IBOutlet weak var contentDescLabel: UILabel!
    
    @IBOutlet weak var descNoPicTitleLabel: UILabel!
    
    @IBOutlet weak var poemTitleLabel: UILabel!
    
    @IBOutlet weak var poemAuthorLabel: UILabel!
    
    @IBOutlet weak var poemAuthorImageView: UIImageView!
    
    @IBOutlet weak var poemContentLabel: UILabel!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentImageView.hidden = true
        descNoPicTitleLabel.hidden = true
        contentDescView.hidden = true
        descNoPicTitleLabel.backgroundColor = UIColor.groupTableViewBackgroundColor()
        descNoPicTitleLabel.layer.cornerRadius = 5
        descNoPicTitleLabel.clipsToBounds = true
        userNameLabel.font = UIFont.userFontWithSize(16)
        userTimeLabel.font = UIFont.userFontWithSize(14)
        descNoPicTitleLabel.font = UIFont.systemFontOfSize(28, weight: UIFontWeightMedium)
        contentDescLabel.font = UIFont.userFontWithSize(17)
        poemTitleLabel.font = UIFont.userFontWithSize(17)
        poemAuthorLabel.font = UIFont.userFontWithSize(14)
        poemContentLabel.font = UIFont.userFontWithSize(15)
        shareButton.titleLabel?.font = UIFont.userFontWithSize(15)
        commentButton.titleLabel?.font = UIFont.userFontWithSize(15)
        likeButton.titleLabel?.font = UIFont.userFontWithSize(15)
        contentImageView.backgroundColor = UIColor.init(red: 0xa0/225.0, green: 0xa0/225.0, blue: 0xa0/225.0, alpha: 1.0)
        NSNotificationCenter.defaultCenter().addObserverForName("UserFontChangeNotif", object: nil, queue: NSOperationQueue.mainQueue()) { (_) in
            self.descNoPicTitleLabel.layer.cornerRadius = 5
            self.descNoPicTitleLabel.clipsToBounds = true
            self.userNameLabel.font = UIFont.userFontWithSize(16)
            self.userTimeLabel.font = UIFont.userFontWithSize(14)
            self.descNoPicTitleLabel.font = UIFont.systemFontOfSize(28, weight: UIFontWeightMedium)
            self.contentDescLabel.font = UIFont.userFontWithSize(17)
            self.poemTitleLabel.font = UIFont.userFontWithSize(17)
            self.poemAuthorLabel.font = UIFont.userFontWithSize(14)
            self.poemContentLabel.font = UIFont.userFontWithSize(15)
            self.shareButton.titleLabel?.font = UIFont.userFontWithSize(15)
            self.commentButton.titleLabel?.font = UIFont.userFontWithSize(15)
            self.likeButton.titleLabel?.font = UIFont.userFontWithSize(15)
        }
    }
    
    
    @IBAction func gotoPoemDetail(sender: AnyObject) {
        if let poemVC = UIStoryboard(name:"Recommend", bundle: nil).instantiateViewControllerWithIdentifier("poemvc") as? PoemDetailViewController {
            poemVC.poem = feed?.poem
            viewController?.navigationController?.pushViewController(poemVC, animated: true)
        }
    }
    
    @IBAction func gotoComment(sender: AnyObject) {
        if let poemVC = UIStoryboard(name:"Recommend", bundle: nil).instantiateViewControllerWithIdentifier("poemvc") as? PoemDetailViewController {
            poemVC.poem = feed?.poem
            viewController?.navigationController?.pushViewController(poemVC, animated: true)
        }
    }
    
    @IBAction func gotoShare(sender: AnyObject) {
        if let poemVC = UIStoryboard(name:"Recommend", bundle: nil).instantiateViewControllerWithIdentifier("poemvc") as? PoemDetailViewController {
            poemVC.poem = feed?.poem
            viewController?.navigationController?.pushViewController(poemVC, animated: true)
        }
    }
    
    @IBAction func onLike(sender: AnyObject) {
        if let poemVC = UIStoryboard(name:"Recommend", bundle: nil).instantiateViewControllerWithIdentifier("poemvc") as? PoemDetailViewController {
            poemVC.poem = feed?.poem
            viewController?.navigationController?.pushViewController(poemVC, animated: true)
        }
    }
    
    var feed:Feed? {
        didSet {
            if let feed = feed {
                userImageView.af_setImageWithURL(NSURL(string:feed.user?.avatar ?? "") ?? NSURL(), placeholderImage: UIImage(named:"defaulticon"))
                userNameLabel.text = feed.user?.nick ?? User.LoginUser?.nick ?? "匿名用户"
                userTimeLabel.text = feed.time
                poemTitleLabel.text = feed.poem?.title
                feed.poem?.loadPoet()
                poemAuthorLabel.text = feed.poem?.poet?.name
                poemContentLabel.text = feed.poem?.content.trimString()
                likeButton.setTitle("喜欢(\(feed.likeCount))", forState: .Normal)
                commentButton.setTitle("评论(\(feed.commentCount))", forState: .Normal)
                
                let url = feed.poem?.poet?.name.iconURL() ?? ""
                poemAuthorImageView.af_setImageWithURL(NSURL(string:url) ?? NSURL(), placeholderImage: UIImage(named:"defaulticon"))
                
                var hasPic = false
                if let url = NSURL(string: feed.picture) where feed.picture.hasPrefix("http") {
                    hasPic = true
                    self.contentImageView.hidden = false
                    self.descNoPicTitleLabel.hidden = true
                    self.contentDescLabel.text = feed.content.trimString()
                    self.contentDescView.hidden = false
                    contentImageView.af_setImageWithURL(url)
                }
                if !hasPic {
                    contentDescView.hidden = true
                    contentImageView.hidden = true
                    descNoPicTitleLabel.hidden = false
                    let attrStr = NSMutableAttributedString()
                    attrStr.appendAttributedString(NSAttributedString(string: feed.content.trimString(), attributes: TextAttributes().font(UIFont.userFontWithSize(24)).foregroundColor(UIColor.darkGrayColor())))
                    attrStr.addAttributes(TextAttributes().headIndent(8).firstLineHeadIndent(20))
                    descNoPicTitleLabel.attributedText = attrStr
                    descNoPicTitleLabel.adjustFontSizeToFit()
                }
            }
        }
    }
    
}
