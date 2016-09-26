//
//  LikeViewController.swift
//  poetry
//
//  Created by sunsing on 8/26/16.
//  Copyright © 2016 诺崇. All rights reserved.
//
import UIKit

class ExploreAddViewController: UITableViewController, UITextViewDelegate {
    
    var poem:Poem?
    
    var feed:Feed?

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet  var poemCell: UITableViewCell!
    
    var imageURL:String?
    
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = poem?.title ?? "分享诗词"
        if let feed = feed {
            poem = feed.poem
        }
        if let poem = poem {
            poem.loadPoet()
            poemCell.textLabel?.text = poem.title
            poemCell.detailTextLabel?.text = poem.poet?.name
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if range.location == 0 && text == "\n" {
            return false
        }
        if range.location == 0 && text == " " {
            return false
        }
        if range.location == 0 && text.characters.count > 0 && textView.text == "" {
            tipLabel.isHidden = true
        }
        if range.location == 0 && range.length == 1 && text == "" && textView.text.characters.count > 0 {
            tipLabel.isHidden = false
        }
        return true
    }
    
    @IBAction func addPic(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "上传图片", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "选择照片", style: .default, handler: { (_) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "拍摄照片", style: .default, handler: { (_) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            
        }))
        self.present(alertController, animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { 
            self.textView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    @IBAction func addFeed(_ sender: AnyObject) {
        if textView.text.characters.count == 0 {
            HUD.flash(.error("请输入分享内容"), delay: 1)
            return
        }
        if poem == nil {
            HUD.flash(.error("请选择分享诗词"), delay: 1)
            return
        }
        Feed.AddFeed(poem!.id, content: textView.text, image: imageURL ?? "") { (success, error) in
            if success {
                HUD.flash(.success("分享成功"), delay: 1)
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "AddFeedNotif"), object: nil)
            } else {
                HUD.flash(.error(error!.localizedDescription), delay: 1)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PoemSearchViewController {
            vc.selectPoemAction = {
                self.poem = $0
                self.tableView.reloadData()
            }
        }
    }
}

extension ExploreAddViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
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
        picker.dismiss(animated: true, completion: nil)
    }
}


