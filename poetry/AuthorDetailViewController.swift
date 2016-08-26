//
//  AuthorDetailViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/8/24.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

class AuthorDetailViewController: UIViewController, UITextViewDelegate {
    
    var poet:Poet!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let textView = view.viewWithTag(1) as? UITextView {
            textView.delegate = self
            textView.font = UIFont.userFontWithSize(15)
            textView.text = poet.desc
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
