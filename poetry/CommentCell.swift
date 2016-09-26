//
//  CommentCell.swift
//  poetry
//
//  Created by sunsing on 8/29/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import TextAttributes

class CommentCell: UITableViewCell {
    
    var likeCommentAction: ((Comment) -> Void)?
    
    var replyCommentAction: ((Comment) -> Void)?
    
    var showUserAction : ((User?) -> Void)?

    @IBOutlet var headImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var thumbButton: UIButton!
    
    @IBAction func clickThumb(_ sender: UIButton) {
        if comment.isFav {
            User.LoginUser?.unlikeComment(cid: comment.id, finish: { (cmt, err) in
                if err == nil && cmt != nil {
                    self.thumbButton.setTitle("\(cmt!.likeCount)", for: .normal)
                    self.thumbButton.setImage(UIImage(named:"hert") , for: UIControlState())
                    self.thumbButton.tintColor = UIColor.darkGray
                    self.comment.isFav = false
                    self.comment.likeCount = cmt!.likeCount
                }
            })
            return
        }
        User.LoginUser?.likeComment(cid: comment.id, finish: { (cmt, err) in
            if err == nil && cmt != nil {
                self.thumbButton.setTitle("\(cmt!.likeCount)", for: .normal)
                self.thumbButton.setImage(UIImage(named:"heart") , for: UIControlState())
                self.thumbButton.tintColor = UIColor.flatRed()
                self.comment.isFav = true
                self.comment.likeCount = cmt!.likeCount
            }
        })
        likeCommentAction?(comment)
    }
    
    @IBAction func clickComment(_ sender: UIButton) {
        replyCommentAction?(comment)
    }
    
    @IBOutlet weak var contentTextLabel: TTTAttributedLabel!
    
    @IBOutlet weak var commentTextLabel: TTTAttributedLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commentTextLabel.linkAttributes = [NSForegroundColorAttributeName: UIColor.flatSkyBlue()]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layoutIfNeeded()
        self.contentTextLabel.preferredMaxLayoutWidth = self.contentTextLabel.frame.size.width
        self.commentTextLabel.preferredMaxLayoutWidth = self.commentTextLabel.frame.size.width
    }
    
    @IBAction func showUserInfo(_ sender: AnyObject) {
        showUserAction?(comment.user)
    }
    
    var comment:Comment! {
        didSet {
            if let url = URL(string: comment.user?.avatar ?? "") {
                headImageView.af_setImage(withURL: url, placeholderImage: UIImage(named:"defaulticon"))
            } else {
                headImageView.image = UIImage(named: "defaulticon")
            }
            nameLabel.text = comment.user?.nick
            timeLabel.text = comment.time
            thumbButton.setTitle("\(comment.likeCount)", for: .normal)
            thumbButton.setImage(UIImage(named: comment.isFav ? "heart" : "hert") , for: UIControlState())
            thumbButton.tintColor = comment.isFav ? UIColor.flatRed() : UIColor.darkGray
            if let rc = comment.comment {
                commentTextLabel.text = "@\(rc.user!.nick):" + rc.content
                commentTextLabel.addLink(toTransitInformation: ["user":rc.user], with: NSMakeRange(1, rc.user!.nick.characters.count)).linkTapBlock = {
                    _, _ in
                    self.showUserAction?(rc.user)
                }
                commentTextLabel.lineHeightMultiple = 1.1
                commentTextLabel.textInsets = UIEdgeInsetsMake(8, 8, 8, 8)
            } else {
                commentTextLabel.text = nil
            }
            contentTextLabel.text = comment.content
        }
    }
}
