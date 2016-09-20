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
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var descLabel: UILabel!

    override func awakeFromNib() {
        titleLabel.font = UIFont.userFont(size:20)
        descLabel.font = UIFont.userFont(size:15)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserFontChangeNotif"), object: nil, queue: OperationQueue.main) { (_) in
            self.titleLabel.font = UIFont.userFont(size:18)
            self.descLabel.font = UIFont.userFont(size:15)
        }
    }
    
    var data:Poem! {
        didSet {
            if data == nil {
                return
            }
            if let url = URL(string:data.poet?.name.iconURL() ?? "") {
                headImageView.af_setImage(withURL:url, placeholderImage: UIImage.imageWithString(data.poet?.name ?? "", size: CGSize(width: 80, height: 80)))
            } else {
                headImageView.image = UIImage.imageWithString(data.poet?.name ?? "", size: CGSize(width: 80, height: 80))
            }
            titleLabel.text = data.title + "◦" + (data.poet?.name ?? "无名氏")
            descLabel.text = data.content
        }
    }
}
