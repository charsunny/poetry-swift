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
    
    @IBOutlet var titleLabel:UILabel!
    
    @IBOutlet var descLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.font = UIFont.userFont(size:18)
        descLabel.font = UIFont.userFont(size:14)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserFontChangeNotif"), object: nil, queue: OperationQueue.main) { (_) in
            self.titleLabel.font = UIFont.userFont(size:18)
            self.descLabel.font = UIFont.userFont(size:14)
        }
    }
    
    var poem:Poem? {
        didSet {
            if let data = poem {
                data.loadPoet()
                if let url = URL(string:data.poet?.name.iconURL() ?? "") {
                    headImageView.af_setImage(withURL:url, placeholderImage: UIImage.imageWithString(data.poet?.name ?? "", size: CGSize(width: 80, height: 80)))
                } else {
                    headImageView.image = UIImage.imageWithString(data.poet?.name ?? "", size: CGSize(width: 80, height: 80))
                }
                titleLabel.text =  (data.poet?.name ?? "无名氏") + "◦"  + data.title
                let content = data.content.trimString()
                descLabel.text = content
            }
        }
    }
    
    var explain:(String, String)? {
        didSet {
            if let data = explain {
                headImageView.image = UIImage.imageWithString(data.0, size: CGSize(width: 80, height: 80))
                titleLabel.text =  data.0
                descLabel.text = data.1
            }
        }
    }
    
    var poet:Poet? {
        didSet {
            if let data = poet {
                if let url = URL(string:data.name.iconURL()) {
                    headImageView.af_setImage(withURL:url, placeholderImage: UIImage.imageWithString(data.name, size: CGSize(width: 80, height: 80)))
                } else {
                    headImageView.image = UIImage.imageWithString(data.name, size: CGSize(width: 80, height: 80))
                }
                titleLabel.text = data.name
                descLabel.text = data.desc
            }
        }
    }
    
    var format:PoemFormat? {
        didSet {
            if let data = format {
                headImageView.image =  UIImage.imageWithString(data.name, size: CGSize(width: 80, height: 80))
                descLabel.text = data.desc
                titleLabel.text = data.name
            }
        }
    }
    
}
