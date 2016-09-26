//
//  ColumnAddViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/9/2.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

class ColumnAddViewController: UITableViewController {
    
    var poems:[Poem] = []
    var poets:[Poet] = []
    
    var imageURL:String = ""
    
    @IBOutlet weak var titleField: UITextField!
    
    @IBOutlet weak var imageButton: UIButton!
    
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SearchResultCell", bundle:nil), forCellReuseIdentifier: "cell")
        
    }
    
    @IBAction func onCreateFinish(_ sender: AnyObject) {
        guard let title = titleField.text, title.characters.count > 0 else {
            HUD.flash(.error("请输入标题"), delay: 3.0)
            return
        }
        guard let desc = textView.text, desc.characters.count > 0 else {
            HUD.flash(.error("请输入描述"), delay: 3.0)
            return
        }
        var pids = ""
        var type = 0
        if segControl.selectedSegmentIndex == 0 {
            pids = poems.reduce(""){ return $0 + "|" + String($1.id)}
            type = 0
        } else {
            pids = poets.reduce(""){ return $0 + "|" + String($1.id)}
            type = 1
        }
        Column.AddColumn(name: title, desc: desc, image: imageURL, type: type, pids: pids) {(col, err) in
            if err != nil {
                HUD.flash(.error(err!.localizedDescription), delay: 2.0)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ColumnAddSuccessNotif"), object: col)
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
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
            return 2
        }
        return poems.count
    }
    
    lazy var segControl : UISegmentedControl = {
        let seg = UISegmentedControl(items: ["诗词", "诗人"])
        seg.setWidth(50, forSegmentAt: 0)
        seg.setWidth(50, forSegmentAt: 1)
        seg.selectedSegmentIndex = 0
        seg.addTarget(self, action: #selector(ColumnAddViewController.segValueChanged(seg:)), for: .valueChanged)
        return seg
    } ()
    
    func segValueChanged(seg : UISegmentedControl) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "hcell", for: indexPath)
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "专辑类型"
                cell.detailTextLabel?.text = nil
                cell.accessoryView = segControl
            } else {
                if segControl.selectedSegmentIndex == 0 {
                    cell.textLabel?.text = "添加诗词"
                    cell.detailTextLabel?.text = "已选择\(poems.count)首"
                } else {
                    cell.textLabel?.text = "添加诗人"
                    cell.detailTextLabel?.text = "已选择\(poets.count)人"
                }
                cell.accessoryType = .disclosureIndicator
            }
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchResultCell
        if segControl.selectedSegmentIndex == 0 {
            cell.poem = poems[indexPath.row]
        } else {
            cell.poet = poets[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 50
        }
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.endEditing(true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PoemSearchViewController {
            if segControl.selectedSegmentIndex == 0 {
                vc.poemSearchType = .poem
                vc.selectPoemAction = {
                    self.poems.insert($0, at: 0)
                    self.tableView.reloadData()
                }
            } else {
                vc.poemSearchType = .poet
                vc.selectPoetAction = {
                    self.poets.insert($0, at: 0)
                    self.tableView.reloadData()
                }
            }
        }
    }

}

extension ColumnAddViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
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

