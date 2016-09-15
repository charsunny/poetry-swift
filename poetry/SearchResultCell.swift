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
        imageLabel.font = UIFont.userFont(size:14)
        titleLabel.font = UIFont.userFont(size:16)
        descLabel.font = UIFont.userFont(size:15)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserFontChangeNotif"), object: nil, queue: OperationQueue.main) { (_) in
            self.imageLabel.font = UIFont.userFont(size:14)
            self.titleLabel.font = UIFont.userFont(size:16)
            self.descLabel.font = UIFont.userFont(size:15)
        }
    }
    
    var poem:Poem? {
        didSet {
            if let data = poem {
                data.loadPoet()
                let url = data.poet?.name.iconURL() ?? ""
                headImageView.af_setImage(withURL:URL(string:url)!, placeholderImage: UIImage(named:"defaulticon"))
                titleLabel.text = data.title
                let content = data.content.replacingOccurrences(of: "，\r\n", with: "，")
                descLabel.text = content
                imageLabel.text = data.poet?.name
            }
        }
    }
    
    var poet:Poet? {
        didSet {
            if let data = poet {
                let url = data.name.iconURL()
                headImageView.af_setImage(withURL:URL(string:url)!, placeholderImage: UIImage(named:"defaulticon"))
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
                headImageView.image =  UIImage.imageWithString(data.name, size: CGSize(width: 80, height: 80))
                titleLabel.text = nil
                descLabel.text = data.desc
                titleLabel.text = nil
                imageLabel.text = nil
            }
        }
    }
    
}
