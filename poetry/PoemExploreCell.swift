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
        contentImageView.isHidden = true
        descNoPicTitleLabel.isHidden = true
        contentDescView.isHidden = true
        descNoPicTitleLabel.backgroundColor = UIColor.groupTableViewBackground
        descNoPicTitleLabel.layer.cornerRadius = 5
        descNoPicTitleLabel.clipsToBounds = true
        userNameLabel.font = UIFont.userFont(size:16)
        userTimeLabel.font = UIFont.userFont(size:14)
        descNoPicTitleLabel.font = UIFont.systemFont(ofSize: 28, weight: UIFontWeightMedium)
        contentDescLabel.font = UIFont.userFont(size:17)
        poemTitleLabel.font = UIFont.userFont(size:17)
        poemAuthorLabel.font = UIFont.userFont(size:14)
        poemContentLabel.font = UIFont.userFont(size:15)
        shareButton.titleLabel?.font = UIFont.userFont(size:15)
        commentButton.titleLabel?.font = UIFont.userFont(size:15)
        likeButton.titleLabel?.font = UIFont.userFont(size:15)
        contentImageView.backgroundColor = UIColor.init(red: 0xa0/225.0, green: 0xa0/225.0, blue: 0xa0/225.0, alpha: 1.0)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserFontChangeNotif"), object: nil, queue: OperationQueue.main) { (_) in
            self.descNoPicTitleLabel.layer.cornerRadius = 5
            self.descNoPicTitleLabel.clipsToBounds = true
            self.userNameLabel.font = UIFont.userFont(size:16)
            self.userTimeLabel.font = UIFont.userFont(size:14)
            self.descNoPicTitleLabel.font = UIFont.systemFont(ofSize: 28, weight: UIFontWeightMedium)
            self.contentDescLabel.font = UIFont.userFont(size:17)
            self.poemTitleLabel.font = UIFont.userFont(size:17)
            self.poemAuthorLabel.font = UIFont.userFont(size:14)
            self.poemContentLabel.font = UIFont.userFont(size:15)
            self.shareButton.titleLabel?.font = UIFont.userFont(size:15)
            self.commentButton.titleLabel?.font = UIFont.userFont(size:15)
            self.likeButton.titleLabel?.font = UIFont.userFont(size:15)
        }
    }
    
    
    @IBAction func gotoPoemDetail(_ sender: AnyObject) {
        if let poemVC = UIStoryboard(name:"Recommend", bundle: nil).instantiateViewController(withIdentifier: "poemvc") as? PoemDetailViewController {
            poemVC.poem = feed?.poem
            viewController?.navigationController?.pushViewController(poemVC, animated: true)
        }
    }
    
    @IBAction func gotoComment(_ sender: AnyObject) {
        if let poemVC = UIStoryboard(name:"Recommend", bundle: nil).instantiateViewController(withIdentifier: "poemvc") as? PoemDetailViewController {
            poemVC.poem = feed?.poem
            viewController?.navigationController?.pushViewController(poemVC, animated: true)
        }
    }
    
    @IBAction func gotoShare(_ sender: AnyObject) {
        if let poemVC = UIStoryboard(name:"Recommend", bundle: nil).instantiateViewController(withIdentifier: "poemvc") as? PoemDetailViewController {
            poemVC.poem = feed?.poem
            viewController?.navigationController?.pushViewController(poemVC, animated: true)
        }
    }
    
    @IBAction func onLike(_ sender: AnyObject) {
        if let poemVC = UIStoryboard(name:"Recommend", bundle: nil).instantiateViewController(withIdentifier: "poemvc") as? PoemDetailViewController {
            poemVC.poem = feed?.poem
            viewController?.navigationController?.pushViewController(poemVC, animated: true)
        }
    }
    
    var feed:Feed? {
        didSet {
            if let feed = feed {
                userImageView.af_setImage(withURL:URL(string:feed.user?.avatar ?? "")!, placeholderImage: UIImage(named:"defaulticon"))
                userNameLabel.text = feed.user?.nick ?? User.LoginUser?.nick ?? "匿名用户"
                userTimeLabel.text = feed.time
                poemTitleLabel.text = feed.poem?.title
                feed.poem?.loadPoet()
                poemAuthorLabel.text = feed.poem?.poet?.name
                poemContentLabel.text = feed.poem?.content.trimString()
                likeButton.setTitle("喜欢(\(feed.likeCount))", for: UIControlState())
                commentButton.setTitle("评论(\(feed.commentCount))", for: UIControlState())
                
                let url = feed.poem?.poet?.name.iconURL() ?? ""
                poemAuthorImageView.af_setImage(withURL:URL(string:url)!, placeholderImage: UIImage(named:"defaulticon"))
                
                var hasPic = false
                if let url = URL(string: feed.picture) , feed.picture.hasPrefix("http") {
                    hasPic = true
                    self.contentImageView.isHidden = false
                    self.descNoPicTitleLabel.isHidden = true
                    self.contentDescLabel.text = feed.content.trimString()
                    self.contentDescView.isHidden = false
                    contentImageView.af_setImage(withURL:url)
                }
                if !hasPic {
                    contentDescView.isHidden = true
                    contentImageView.isHidden = true
                    descNoPicTitleLabel.isHidden = false
                    let attrStr = NSMutableAttributedString()
                    attrStr.append(NSAttributedString(string: feed.content.trimString(), attributes: TextAttributes().font(UIFont.userFont(size:24)).foregroundColor(UIColor.darkGray)))
                    attrStr.addAttributes(TextAttributes().headIndent(8).firstLineHeadIndent(20))
                    descNoPicTitleLabel.attributedText = attrStr
                    descNoPicTitleLabel.adjustFontSizeToFit()
                }
            }
        }
    }
    
}
