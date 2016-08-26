//
//  LikeViewController.swift
//  poetry
//
//  Created by sunsing on 8/26/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit

class LikeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        var frame = self.view.frame
        frame.origin.y = frame.origin.y - 100
        self.view.frame = frame
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        var frame = self.view.frame
        frame.origin.y = frame.origin.y + 100
        self.view.frame = frame
        return true
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
