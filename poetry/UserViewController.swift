//
//  UserViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/10.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

class UserViewController: UITableViewController {

    @IBOutlet weak var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.backgroundColor = UIColor.flatRedColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.hidden = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.hidden = false
    }
    

    override func viewDidLayoutSubviews() {
        let offset = tableView.contentOffset
        headerView.frame = CGRect(x: 0, y: offset.y, width: headerView.frame.width, height: 180 - offset.y)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 11
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50
        }
        return 424
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("hcell", forIndexPath: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        return cell
    }
    
}
