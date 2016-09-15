//
//  SettingViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/8/26.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {

    @IBOutlet weak var fontChooseCell: UITableViewCell!
    
    @IBOutlet weak var bgMusicCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let switcher = UISwitch()
        switcher.onTintColor = UIColor.flatRedColorDark()
        switcher.addTarget(self, action: #selector(switchBgMusic(_:)), for: .valueChanged)
        switcher.isOn = !User.BgMusicOff
        bgMusicCell.accessoryView = switcher
    }
    
    func switchBgMusic(_ swicther:UISwitch) {
        User.BgMusicOff = !User.BgMusicOff
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let font = CustomFonts.filter({$0.1 == User.Font}).first?.0 {
            fontChooseCell.detailTextLabel?.text = font
        } else {
            fontChooseCell.detailTextLabel?.text = ""
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
