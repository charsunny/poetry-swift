//
//  FontChooseViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/9/2.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

 let CustomFonts = [("汉仪全唐诗简体", "HYQuanTangShiJ"), ("汉仪全唐诗繁体", "HYQuanTangShiF"), ("方正宋刻本秀楷简体" , "FZSongKeBenXiuKaiS-R-GB"), ("方正宋刻本秀楷繁体" , "FZSongKeBenXiuKaiT-R-GB"), ("方正北魏楷书简体" , "FZBeiWeiKaiShu-S19S"), ("方正北魏楷书繁体" , "FZBeiWeiKaiShu-Z15T"), ("系统字体", "system")]

class FontChooseViewController: UITableViewController {
    
   

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.font = UIFont.userFont(size:28)
        descLabel.font = UIFont.userFont(size:17)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return CustomFonts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.font = UIFont.userFont(size:17)
        cell.textLabel?.text = CustomFonts[(indexPath as NSIndexPath).row].0
        
        if User.Font == CustomFonts[(indexPath as NSIndexPath).row].1 {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        User.Font = CustomFonts[(indexPath as NSIndexPath).row].1
        titleLabel.font = UIFont.userFont(size:28)
        descLabel.font = UIFont.userFont(size:17)
        tableView.reloadData()
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
