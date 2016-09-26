//
//  RecommendAddViewController.swift
//  poetry
//
//  Created by sunsing on 9/2/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit

class RecommendAddViewController: UITableViewController {
    
    var poems:[Poem] = []
    
    var imageURL:String = ""
    
    @IBOutlet weak var imageButton: UIButton!
    
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //textView.becomeFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return poems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "hcell", for: indexPath)

            // Configure the cell...

            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // Configure the cell...
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 50
        }
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endEditing(true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PoemSearchViewController {
            if sender is UITableViewCell {
                vc.poemSearchType = .poem
            } else {
                vc.poemSearchType = .dict
            }
            vc.selectExplainAction = {
                debugPrint($0)
            }
            vc.selectPoemAction = {
                debugPrint($0)
            }
        }
    }

}

extension RecommendAddViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            let data = UIImageJPEGRepresentation(image, 0.5)
            let image = UIImage(data: data!)
            self.imageButton.setImage(image, for: .normal)
            User.UploadPic(image!, finish: {
                if $0.0 {
                    self.imageURL = $0.1 ?? ""
                } else {
                    self.imageButton.setImage(UIImage(named:"addpic")!, for: .normal)
                }
            })
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
