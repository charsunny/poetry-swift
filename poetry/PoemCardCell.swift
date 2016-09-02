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
        descNoPicTitleLabel.font = UIFont.systemFontOfSize(28, weight: UIFontWeightMedium)
        contentDescLabel.font = UIFont.userFontWithSize(17)
        poemTitleLabel.font = UIFont.userFontWithSize(17)
        poemAuthorLabel.font = UIFont.userFontWithSize(14)
        poemContentLabel.font = UIFont.userFontWithSize(15)
        agreeButton.titleLabel?.font = UIFont.userFontWithSize(15)
        commentButton.titleLabel?.font = UIFont.userFontWithSize(15)
        likeButton.titleLabel?.font = UIFont.userFontWithSize(15)
    }
    
    
    @IBAction func gotoPoemDetail(sender: AnyObject) {
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
                            self.contentDescLabel.text = feed.content.trimString()
                            self.contentDescView.hidden = false
                        }
                    }
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

extension UILabel {
    func adjustFontSizeToFit() {
        var font = self.font;
        let size = self.frame.size;
        var maxSize = self.font.pointSize
        
        for ; maxSize >= self.minimumScaleFactor * self.font.pointSize; maxSize = maxSize - 1 {
            font = font.fontWithSize(maxSize)
            let constraintSize = CGSizeMake(size.width, CGFloat.max);
            
            if let textRect = self.text?.boundingRectWithSize(constraintSize, options:.UsesLineFragmentOrigin, attributes:[NSFontAttributeName:font], context:nil) {
                let  labelSize = textRect.size;
                if(labelSize.height <= size.height || maxSize < 13) {
                    self.font = font
                    self.setNeedsLayout()
                    break
                }
            }
            
        }
        // set the font to the minimum size anyway
        self.font = font;
        self.setNeedsLayout()
    }
}
