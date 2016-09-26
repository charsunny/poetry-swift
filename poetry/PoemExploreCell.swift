//
//  PoemExploreCell.swift
//  poetry
//
//  Created by Xi Sun on 16/9/2.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import TextAttributes
import TTTAttributedLabel

class PoemExploreCell: UITableViewCell {
    
    var likeAction: ((Feed) -> Void)?
    
    var shareAction: ((Feed) -> Void)?
    
    var commentAction: ((Feed) -> Void)?
    
    var showUserAction : ((User?) -> Void)?
    
    var showPoemAction : ((Poem?) -> Void)?
    
    var showMenuAction : ((Feed) -> Void)?
    
    var showPicAction : ((Feed) -> Void)?
    
    @IBOutlet weak var forwardLabel: UILabel!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userTimeLabel: UILabel!
    
    @IBOutlet weak var contentImageView: UIImageView!
    
    @IBOutlet weak var contentDescView: UIView!
    
    @IBOutlet weak var contentDescLabel: UILabel!
    
    @IBOutlet weak var descNoPicTitleLabel: TTTAttributedLabel!
    
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
        userNameLabel.font = UIFont.systemFont(ofSize:14)
        userTimeLabel.font = UIFont.systemFont(ofSize:13)
        descNoPicTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightLight)
        descNoPicTitleLabel.textInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        contentDescLabel.font = UIFont.systemFont(ofSize:15)
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
            self.poemTitleLabel.font = UIFont.userFont(size:17)
            self.poemAuthorLabel.font = UIFont.userFont(size:14)
            self.shareButton.titleLabel?.font = UIFont.userFont(size:15)
            self.commentButton.titleLabel?.font = UIFont.userFont(size:15)
            self.likeButton.titleLabel?.font = UIFont.userFont(size:15)
            self.poemContentLabel.font = UIFont.userFont(size:15)
        }
        contentImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PoemExploreCell.showPic)))
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PoemExploreCell.showUser)))
    }
    
    
    func showPic() {
        showPicAction?(feed)
    }
    
    func showUser() {
        showUserAction?(feed.user)
    }
    
    @IBAction func gotoPoemDetail(_ sender: AnyObject) {
        showPoemAction?(feed.poem)
    }
    
    @IBAction func gotoComment(_ sender: AnyObject) {
        commentAction?(feed)
    }
    
    @IBAction func gotoShare(_ sender: AnyObject) {
        shareAction?(feed)
    }
    
    @IBAction func onLike(_ sender: AnyObject) {
        if feed.isFav {
            User.LoginUser?.unlikeFeed(cid: feed.id, finish: { (cmt, err) in
                if err == nil && cmt != nil {
                    self.likeButton.setTitle("喜欢(\(cmt!.likeCount))", for: .normal)
                    self.likeButton.tintColor = UIColor.darkGray
                    self.feed.isFav = false
                    self.feed.likeCount = cmt!.likeCount
                }
            })
            return
        }
        User.LoginUser?.likeFeed(cid: feed.id, finish: { (cmt, err) in
            if err == nil && cmt != nil {
                self.likeButton.setTitle("喜欢(\(cmt!.likeCount))", for: .normal)
                self.likeButton.tintColor = UIColor.flatRed()
                self.feed.isFav = true
                self.feed.likeCount = cmt!.likeCount
            }
        })

        likeAction?(feed)
    }
    
    var feed:Feed! {
        didSet {
            if let feed = feed {
                if let url = URL(string:feed.user?.avatar ?? "") {
                    userImageView.af_setImage(withURL:url, placeholderImage: UIImage(named:"defaulticon"))
                } else {
                    userImageView.image = UIImage(named:"defaulticon")
                }
                userNameLabel.text = feed.user?.nick ?? User.LoginUser?.nick ?? "匿名用户"
                userTimeLabel.text = feed.time
                poemTitleLabel.text = feed.poem?.title
                feed.poem?.loadPoet()
                poemAuthorLabel.text = feed.poem?.poet?.name
                poemContentLabel.text = feed.poem?.content.trimString()
                likeButton.tintColor = feed.isFav ? UIColor.flatRed() : UIColor.darkGray
                likeButton.setTitle("喜欢(\(feed.likeCount))", for: UIControlState())
                commentButton.setTitle("评论(\(feed.commentCount))", for: UIControlState())
                
                if let str = feed.poem?.poet?.name.iconURL(), str.characters.count > 0 {
                    if let url = URL(string: str) {
                        poemAuthorImageView.af_setImage(withURL:url, placeholderImage: UIImage.imageWithString(feed.poem?.poet?.name ?? "", size: CGSize(width: 80, height: 80)))
                    } else {
                        poemAuthorImageView.image = UIImage.imageWithString(feed.poem?.poet?.name ?? "", size: CGSize(width: 80, height: 80))
                    }
                } else {
                    poemAuthorImageView.image = UIImage.imageWithString(feed.poem?.poet?.name ?? "", size: CGSize(width: 80, height: 80))
                }
                
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
                    attrStr.addAttributes(TextAttributes().headIndent(8).firstLineHeadIndent(32))
                    descNoPicTitleLabel.text = feed.content.trimString()
                    descNoPicTitleLabel.adjustFontSizeToFit()
                }
            }
        }
    }
    
}
