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
    
    @IBOutlet var scrollView:UIScrollView!
    
    var textViews : [UITextView] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        var i = 0;
        while i < 3 {
            let textView = UITextView()
            textView.isEditable = false
            textView.frame = CGRect(x: scrollView.frame.size.width*CGFloat(i), y: 0, width: self.frame.size.width, height: self.frame.size.height)
            scrollView.addSubview(textView)
            textViews.append(textView)
            i = i + 1
        }
    }
    
    override func layoutSubviews() {
        var i = 0
        scrollView.contentSize = CGSize(width: (self.frame.size.width - 16)*3, height: self.frame.size.height - 16)
        for textView in textViews {
            textView.frame = CGRect(x: (self.frame.size.width - 16)*CGFloat(i), y: 0, width: self.frame.size.width - 16, height: self.scrollView.frame.size.height - 16)
            i = i + 1
        }
    }
    
    var poem:Poem? {
        didSet {
            if let poem = poem {
                
                poem.loadPoet()
                
                let textStr = NSMutableAttributedString()
                
                let titleAttributes = TextAttributes()
                titleAttributes.font(UIFont.userFont(size:20)).lineSpacing(20).alignment(.center).foregroundColor(UIColor.darkText)
                textStr.append(NSAttributedString(string: poem.title , attributes: titleAttributes))
                textStr.append(NSAttributedString(string: "\n"))
                
                let authorAttributes = TextAttributes()
                authorAttributes.font(UIFont.userFont(size:15)).lineSpacing(8).alignment(.right).foregroundColor(UIColor.darkGray)
                textStr.append(NSAttributedString(string: poem.poet?.name ?? "", attributes: authorAttributes))
                textStr.append(NSAttributedString(string: "\n"))
                
                let textAttributes = TextAttributes()
                textAttributes.font(UIFont.userFont(size:18)).lineHeightMultiple(1.4).alignment(.center).baselineOffset(8).foregroundColor(UIColor.darkText).headIndent(8)
                textStr.append(NSAttributedString(string: poem.content , attributes: textAttributes))
                
                self.textViews[0].attributedText = textStr
                self.textViews[0].contentOffset = CGPoint.zero
            }
        }
    }
    
    var poet:Poet? {
        didSet {
            if let poet = poet {
                let attrStr = NSMutableAttributedString(string: poet.desc.characters.count == 0 ? "暂无简介" : poet.desc , attributes: [NSFontAttributeName:UIFont.userFont(size:15), NSForegroundColorAttributeName:UIColor.black])
                let imageFilter = ScaledToSizeWithRoundedCornersFilter(size: CGSize(width:80, height:80), radius: 40)
                UIImageView.af_sharedImageDownloader.download(URLRequest(url:URL(string: poet.name.iconURL())!), filter:imageFilter, completion: { (res) in
                    let attachImage = NSTextAttachment()
                    switch res.result {
                    case .success(let value):
                        attachImage.image = value
                    case .failure:
                        attachImage.image = UIImage.imageWithString(poet.name, size: CGSize(width: 80, height: 80))
                    }
                    let attachStr = NSAttributedString(attachment: attachImage)
                    attrStr.insert(attachStr, at: 0)
                    attrStr.insert(NSAttributedString(string:"\n\n\n"), at: 1)
                    attrStr.addAttributes(TextAttributes().alignment(.center), range: NSMakeRange(0, 1))
                    self.textViews[1].attributedText = attrStr
                })
                self.textViews[1].attributedText = attrStr
            }
        }
    }
    
    var format:PoemFormat? {
        didSet {
             if let format = format {
                let attrStr = NSMutableAttributedString(string: format.desc.characters.count == 0 ? "暂无简介" : format.desc , attributes: [NSFontAttributeName:UIFont.userFont(size:15), NSForegroundColorAttributeName:UIColor.black])
                let attachImage = NSTextAttachment()
                attachImage.image = UIImage.imageWithString(format.name, size: CGSize(width: 80, height: 80))
                let attachStr = NSAttributedString(attachment: attachImage)
                attrStr.insert(attachStr, at: 0)
                attrStr.insert(NSAttributedString(string:"\n\n\n"), at: 1)
                attrStr.addAttributes(TextAttributes().alignment(.center), range: NSMakeRange(0, 1))
                textViews[2].attributedText = attrStr
            }
        }
    }
}
