//
//  PoemCardCell.swift
//  poetry
//
//  Created by sunsing on 8/26/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import TextAttributes

class PoemCardCell: UITableViewCell {

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
    
    @IBOutlet weak var agreeButton: UIButton!
    
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
        descNoPicTitleLabel.font = UIFont.userFontWithSize(28)
        contentDescLabel.font = UIFont.userFontWithSize(17)
        poemTitleLabel.font = UIFont.userFontWithSize(16)
        poemAuthorLabel.font = UIFont.userFontWithSize(14)
        poemContentLabel.font = UIFont.userFontWithSize(15)
        agreeButton.titleLabel?.font = UIFont.userFontWithSize(15)
        commentButton.titleLabel?.font = UIFont.userFontWithSize(15)
        likeButton.titleLabel?.font = UIFont.userFontWithSize(15)
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
                poemContentLabel.text = feed.poem?.content
                agreeButton.setTitle("喜欢(\(feed.likeCount))", forState: .Normal)
                commentButton.setTitle("评论(\(feed.commentCount))", forState: .Normal)
                
                let url = feed.poem?.poet?.name.iconURL() ?? ""
                poemAuthorImageView.af_setImageWithURL(NSURL(string:url) ?? NSURL(), placeholderImage: UIImage(named:"defaulticon"))
                
                var hasPic = false
                if let url = NSURL(string: feed.picture) where feed.picture.hasPrefix("http") {
                    hasPic = true
                    contentImageView.af_setImageWithURL(url) {
                        res in
                        if res.result.value != nil {
                            self.contentImageView.hidden = false
                            self.contentImageView.image = res.result.value
                            self.descNoPicTitleLabel.hidden = true
                            self.contentDescLabel.text = feed.content
                            self.contentDescView.hidden = false
                        }
                    }
                }
                if !hasPic {
                    contentDescView.hidden = true
                    contentImageView.hidden = true
                    descNoPicTitleLabel.hidden = false
                    let attrStr = NSMutableAttributedString()
                    let qutoeL = String.fontIconicIcon(code: "double-quote-serif-left")!
                    let qutoeR = String.fontIconicIcon(code: "double-quote-serif-right")!
                    let qfont = UIFont.icon(from: .Iconic, ofSize: 24)
                    let qAttr = TextAttributes().font(qfont).foregroundColor(UIColor.lightGrayColor())
                    let attrLStr = NSAttributedString(string: qutoeL, attributes: qAttr)
                    let attrRStr = NSAttributedString(string: qutoeR, attributes: qAttr)
                    attrStr.appendAttributedString(attrLStr)
                    var content = feed.content
                    if content.characters.count > 60 {
                        content = (content as NSString).substringToIndex(60) + "..."
                    }
                    attrStr.appendAttributedString(NSAttributedString(string: content, attributes: TextAttributes().font(UIFont.userFontWithSize(24)).foregroundColor(UIColor.darkTextColor())))
                    attrStr.appendAttributedString(attrRStr)
                    attrStr.addAttributes(TextAttributes().headIndent(8).lineSpacing(8).firstLineHeadIndent(20))
                    descNoPicTitleLabel.attributedText = attrStr
                }
            }
        }
    }
}
