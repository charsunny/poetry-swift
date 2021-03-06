//
//  AuthorDetailViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/8/24.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import TextAttributes

class AuthorDetailViewController: UIViewController, UITextViewDelegate {
    
    var poet:Poet?
    var format:PoemFormat?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var desc = ""
        if let poet = poet {
            desc = poet.desc
        } else if let format = format {
            desc = format.desc
        }
        if let textView = view.viewWithTag(1) as? UITextView {
            textView.delegate = self
            let attrStr = NSMutableAttributedString(string: desc.characters.count == 0 ? "暂无简介" : desc , attributes: [NSFontAttributeName:UIFont.userFont(size:15), NSForegroundColorAttributeName:UIColor.black])
            let imageFilter = ScaledToSizeWithRoundedCornersFilter(size: CGSize(width:80, height:80), radius: 40)
            if let poet = poet {
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
                    textView.attributedText = attrStr
                })
            } else if let format = format {
                let attachImage = NSTextAttachment()
                attachImage.image = UIImage.imageWithString(format.name, size: CGSize(width: 80, height: 80))
                let attachStr = NSAttributedString(attachment: attachImage)
                attrStr.insert(attachStr, at: 0)
                attrStr.insert(NSAttributedString(string:"\n\n\n"), at: 1)
                attrStr.addAttributes(TextAttributes().alignment(.center), range: NSMakeRange(0, 1))
                textView.attributedText = attrStr
                
            }
            textView.attributedText = attrStr
            
            //let attriString = NS
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let textView = view.viewWithTag(1) as? UITextView {
            textView.contentOffset = CGPoint.zero
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
