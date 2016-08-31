//
//  LikeViewController.swift
//  poetry
//
//  Created by sunsing on 8/26/16.
//  Copyright © 2016 诺崇. All rights reserved.
//
import UIKit
import PKHUD
import KCFloatingActionButton

class ExploreAddViewController: UIViewController, UITextViewDelegate {
    
    var poemId:Int = 0

    @IBOutlet weak var imageView: UIImageView!
    
    var imageURL:String?
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var floatingButton: KCFloatingActionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.floatingButton.hidden = true
        floatingButton.addItem("选择照片", icon: UIImage(named: "photo")) { (_) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .PhotoLibrary
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        floatingButton.addItem("拍摄照片", icon: UIImage(named: "camera")) { (_) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.view.frame = CGRect(x: 20, y: UIScreen.mainScreen().bounds.height/2 - 100, width: UIScreen.mainScreen().bounds.width - 40, height: 200)
        dispatch_async(dispatch_get_main_queue()) { 
            self.textView.becomeFirstResponder()
        }
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        UIView.animateWithDuration(0.3, animations: { 
            var frame = self.view.frame
            frame.origin.y = frame.origin.y - 100
            self.view.frame = frame
        }) { (_) in
            self.floatingButton.hidden = false
        }
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        UIView.animateWithDuration(0.3) {
            var frame = self.view.frame
            frame.origin.y = frame.origin.y + 100
            self.view.frame = frame
        }
        return true
    }
    
    @IBAction func addFeed(sender: AnyObject) {
        if textView.text.characters.count == 0 {
            HUD.flash(.Label("请输入分享内容"), delay: 1)
            return
        }
        Feed.AddFeed(poemId, content: textView.text, image: imageURL ?? "") { (success, error) in
            if success {
                HUD.flash(.LabeledSuccess(title: nil, subtitle: "分享成功"), delay: 1)
                self.dismissViewControllerAnimated(true, completion: nil)
                NSNotificationCenter.defaultCenter().postNotificationName("AddFeedNotif", object: nil)
            } else {
                HUD.flash(.Label(String.ErrorString(error!)), delay: 1)
            }
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

extension ExploreAddViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            let data = UIImageJPEGRepresentation(image, 0.5)
            let image = UIImage(data: data!)
            self.imageView.image = image
            User.UploadPic(image!, finish: {
                if $0.0 {
                    self.imageURL = $0.1
                } else {
                    self.imageView.image = nil
                }
            })
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}


