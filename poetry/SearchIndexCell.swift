//
//  SearchIndexCell.swift
//  poetry
//
//  Created by sunsing on 8/29/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import AlamofireImage
import TextAttributes

class SearchIndexCell: UITableViewCell {
    
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var headImageView:UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var descLabel: UILabel!
    
    
    var textViews : [UITextView] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.font = UIFont.userFont(size: 22)
        descLabel.font = UIFont.userFont(size: 16)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserFontChangeNotif"), object: nil, queue: OperationQueue.main) { (_) in
            self.nameLabel.font = UIFont.userFont(size: 22)
            self.descLabel.font = UIFont.userFont(size: 16)
        }
    }
    
    var poem:Poem? {
        didSet {
            if let poem = poem {
                poem.loadPoet()
                titleLabel.text = "每日诗词"
                nameLabel.text = poem.title
                descLabel.text = poem.content.trimString()
                if let url = URL(string:poem.poet?.name.iconURL() ?? "") {
                    headImageView.af_setImage(withURL:url, placeholderImage: UIImage.imageWithString(poem.poet?.name ?? "", size: CGSize(width: 80, height: 80)))
                } else {
                    headImageView.image = UIImage.imageWithString(poem.poet?.name ?? "", size: CGSize(width: 80, height: 80))
                }
            }
        }
    }
    
    var poet:Poet? {
        didSet {
            if let poet = poet {
                titleLabel.text = "每日诗人"
                nameLabel.text = poet.name
                descLabel.text = poet.desc
                if let url = URL(string:poet.name.iconURL()) {
                    headImageView.af_setImage(withURL:url, placeholderImage: UIImage.imageWithString(poet.name, size: CGSize(width: 80, height: 80)))
                } else {
                    headImageView.image = UIImage.imageWithString(poet.name, size: CGSize(width: 80, height: 80))
                }
            }
        }
    }
    
    var format:PoemFormat? {
        didSet {
             if let format = format {
                titleLabel.text = "每日词牌"
                nameLabel.text = format.name
                descLabel.text = format.desc
                headImageView.image = UIImage.imageWithString(format.name, size: CGSize(width: 80, height: 80))
            }
        }
    }
}
