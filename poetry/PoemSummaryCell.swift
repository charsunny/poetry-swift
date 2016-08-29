//
//  PoemSummaryCell.swift
//  poetry
//
//  Created by sunsing on 8/29/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit

class PoemSummaryCell: UITableViewCell {
    
    @IBOutlet var headImageView: UIImageView!
    
    @IBOutlet var authorLabel: UILabel!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var descLabel: UILabel!

    override func awakeFromNib() {
        titleLabel.font = UIFont(name: UserFont, size: 18)
        descLabel.font = UIFont(name: UserFont, size: 15)
        authorLabel.font = UIFont(name: UserFont, size: 14)
    }
    
    var data:Poem! {
        didSet {
            if data == nil {
                return
            }
            let url = data.poet?.name.iconURL() ?? ""
            headImageView.af_setImageWithURL(NSURL(string:url)!, placeholderImage: UIImage(named:"defaulticon"))
            titleLabel.text = data.title
            descLabel.text = data.content
            authorLabel.text = data.poet?.name
        }
    }
}
