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
        switcher.addTarget(self, action: #selector(switchBgMusic(_:)), forControlEvents: .ValueChanged)
        switcher.on = !User.BgMusicOff
        bgMusicCell.accessoryView = switcher
    }
    
    func switchBgMusic(swicther:UISwitch) {
        User.BgMusicOff = !User.BgMusicOff
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let font = CustomFonts.filter({$0.1 == User.Font}).first?.0 {
            fontChooseCell.detailTextLabel?.text = font
        } else {
            fontChooseCell.detailTextLabel?.text = ""
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
