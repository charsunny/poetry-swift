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
        titleLabel.font = UIFont.userFont(size:18)
        descLabel.font = UIFont.userFont(size:15)
        authorLabel.font = UIFont.userFont(size:14)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserFontChangeNotif"), object: nil, queue: OperationQueue.main) { (_) in
            self.titleLabel.font = UIFont.userFont(size:18)
            self.descLabel.font = UIFont.userFont(size:15)
            self.authorLabel.font = UIFont.userFont(size:14)
        }
    }
    
    var data:Poem! {
        didSet {
            if data == nil {
                return
            }
            let url = data.poet?.name.iconURL() ?? ""
            headImageView.af_setImage(withURL:URL(string:url)!, placeholderImage: UIImage(named:"defaulticon"))
            titleLabel.text = data.title
            descLabel.text = data.content
            authorLabel.text = data.poet?.name
        }
    }
}
