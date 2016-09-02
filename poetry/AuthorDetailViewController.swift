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
            
            let attrStr = NSMutableAttributedString(string: desc.characters.count == 0 ? "暂无简介" : desc , attributes: [NSFontAttributeName:UIFont.userFontWithSize(15), NSForegroundColorAttributeName:UIColor.blackColor()])
            let imageFilter = ScaledToSizeWithRoundedCornersFilter(size: CGSize(width:80, height:80), radius: 40)
            if let poet = poet {
                UIImageView.af_sharedImageDownloader.downloadImage(URLRequest: NSURLRequest(URL:NSURL(string: poet.name.iconURL() ?? "") ?? NSURL()), filter:imageFilter){ (res : Response<Image, NSError>) in
                    let attachImage = NSTextAttachment()
                    res.result.success({ (value) in
                        attachImage.image = value
                    }).failure( { _ in
                        attachImage.image = UIImage(named: "defaulticon")!.af_imageScaledToSize(CGSize(width: 80, height: 80)).af_imageWithRoundedCornerRadius(40)
                    })
                    let attachStr = NSAttributedString(attachment: attachImage)
                    attrStr.insertAttributedString(attachStr, atIndex: 0)
                    attrStr.insertAttributedString(NSAttributedString(string:"\n\n\n"), atIndex: 1)
                    attrStr.addAttributes(TextAttributes().alignment(.Center), range: NSMakeRange(0, 1))
                    textView.attributedText = attrStr
                }
            } else if let format = format {
                let attachImage = NSTextAttachment()
                attachImage.image = UIImage.imageWithString(format.name, size: CGSize(width: 80, height: 80))
                let attachStr = NSAttributedString(attachment: attachImage)
                attrStr.insertAttributedString(attachStr, atIndex: 0)
                attrStr.insertAttributedString(NSAttributedString(string:"\n\n\n"), atIndex: 1)
                attrStr.addAttributes(TextAttributes().alignment(.Center), range: NSMakeRange(0, 1))
                textView.attributedText = attrStr
                
            }
            textView.attributedText = attrStr
            
            //let attriString = NS
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
