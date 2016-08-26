//
//  SearchViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/10.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import TagListView

class SearchViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, TagListViewDelegate {

    var searchController:UISearchController!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self;
        searchController.delegate = self
        //searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.definesPresentationContext = true
        searchController.searchBar.placeholder = "搜索诗人、诗词"
        self.navigationItem.titleView = searchController.searchBar
    }

    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = true
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    let titles = ["今日诗词", "今日词牌", "今日诗人", "热门诗人"]
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 32
        }
        if indexPath.section < 3 {
            return 100
        }
        return 180
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        if indexPath.section < 3 {
            return true
        }
        return false
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("hcell", forIndexPath: indexPath)
            cell.textLabel?.text = titles[indexPath.section]
        } else if indexPath.section < 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier("pcell", forIndexPath: indexPath)
            return cell
        }
        return UITableViewCell()
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
