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
    
    var poem:Poem!

    @IBOutlet weak var imageView: UIImageView!
    
    var imageURL:String?
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = poem.title
    }
    
    @IBAction func addPic(sender: AnyObject) {
        let alertController = UIAlertController(title: "上传图片", message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "选择照片", style: .Default, handler: { (_) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .PhotoLibrary
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "拍摄照片", style: .Default, handler: { (_) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (_) in
            
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dispatch_async(dispatch_get_main_queue()) { 
            self.textView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        return true
    }
    
    @IBAction func addFeed(sender: AnyObject) {
        if textView.text.characters.count == 0 {
            HUD.flash(.Label("请输入分享内容"), delay: 1)
            return
        }
        Feed.AddFeed(poem.id, content: textView.text, image: imageURL ?? "") { (success, error) in
            if success {
                HUD.flash(.LabeledSuccess(title: nil, subtitle: "分享成功"), delay: 1)
                self.dismissViewControllerAnimated(true, completion: nil)
                NSNotificationCenter.defaultCenter().postNotificationName("AddFeedNotif", object: nil)
            } else {
                HUD.flash(.Label(String.ErrorString(error!)), delay: 1)
            }
        }
    }
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


