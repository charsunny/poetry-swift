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
        titleLabel.font = UIFont.userFontWithSize(18)
        descLabel.font = UIFont.userFontWithSize(15)
        authorLabel.font = UIFont.userFontWithSize(14)
        NSNotificationCenter.defaultCenter().addObserverForName("UserFontChangeNotif", object: nil, queue: NSOperationQueue.mainQueue()) { (_) in
            self.titleLabel.font = UIFont.userFontWithSize(18)
            self.descLabel.font = UIFont.userFontWithSize(15)
            self.authorLabel.font = UIFont.userFontWithSize(14)
        }
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
