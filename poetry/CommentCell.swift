//
//  CommentCell.swift
//  poetry
//
//  Created by sunsing on 8/29/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet var headImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var thumbButton: UIButton!
    
    @IBAction func clickThumb(_ sender: UIButton) {
    }
    
     @IBOutlet weak var contentTextLabel: UILabel!
    
    @IBOutlet weak var commentTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
