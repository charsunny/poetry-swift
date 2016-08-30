//
//  SearchResultCell.swift
//  poetry
//
//  Created by sunsing on 8/30/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet var headImageView:UIImageView!
    
    @IBOutlet var imageLabel:UILabel!
    
    @IBOutlet var titleLabel:UILabel!
    
    @IBOutlet var descLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageLabel.font = UIFont.userFontWithSize(13)
        titleLabel.font = UIFont.userFontWithSize(15)
        descLabel.font = UIFont.userFontWithSize(14)
    }
    
    var poem:Poem? {
        didSet {
            if let data = poem {
                data.loadPoet()
                let url = data.poet?.name.iconURL() ?? ""
                headImageView.af_setImageWithURL(NSURL(string:url)!, placeholderImage: UIImage(named:"defaulticon"))
                titleLabel.text = data.title
                let content = data.content.stringByReplacingOccurrencesOfString("，\r\n", withString: "，")
                descLabel.text = content
                imageLabel.text = data.poet?.name
            }
        }
    }
    
    var poet:Poet? {
        didSet {
            if let data = poet {
                let url = data.name.iconURL()
                headImageView.af_setImageWithURL(NSURL(string:url)!, placeholderImage: UIImage(named:"defaulticon"))
                titleLabel.text = nil
                descLabel.text = data.desc
                titleLabel.text = nil
                imageLabel.text = data.name
            }
        }
    }
    
    var format:PoemFormat? {
        didSet {
            if let data = format {
                let url = data.name.iconURL()
                headImageView.af_setImageWithURL(NSURL(string:url)!, placeholderImage: UIImage(named:"defaulticon"))
                titleLabel.text = nil
                descLabel.text = data.desc
                titleLabel.text = nil
                imageLabel.text = data.name
            }
        }
    }
    
}
