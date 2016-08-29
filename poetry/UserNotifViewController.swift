//
//  UserNotifViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/8/26.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import TextAttributes

class UserNotifViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

}

extension UserNotifViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string:"暂无相关动态", attributes: TextAttributes().foregroundColor(UIColor.darkGrayColor()).font(UIFont.userFontWithSize(18)).alignment(.Center))
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "theme\(rand()%7 + 1)")?.af_imageScaledToSize(CGSize(width: 120, height: 120)).af_imageWithRoundedCornerRadius(60)
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return -44
    }
}
