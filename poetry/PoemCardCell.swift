//
//  PoemCardCell.swift
//  poetry
//
//  Created by sunsing on 8/26/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit

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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
