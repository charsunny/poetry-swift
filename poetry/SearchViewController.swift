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
    
    lazy var searchResultVC:SearchResultViewController = {
        let tmpVC = self.storyboard!.instantiateViewControllerWithIdentifier("searchresult") as! SearchResultViewController
        return tmpVC
    }()
    
    lazy var recPoem : Poem? = {
        return DataManager.manager.poemByRowId(self.day%50000)
    }()
    
    lazy var recPoet : Poet? = {
        return DataManager.manager.poetByRowId(self.day%2000)
    }()
    
    lazy var recFormat : PoemFormat? = {
        return DataManager.manager.formatByRowId(self.day%170)
    }()
    
    lazy var day:Int =  {
        let calendaer = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        return abs(calendaer?.components(.Day, fromDate: NSDate(), toDate: NSDate.init(timeIntervalSince1970: 0), options: .WrapComponents).day ?? 1)
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController = UISearchController(searchResultsController: searchResultVC)
        searchController.searchResultsUpdater = self;
        searchController.delegate = self
        //searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.definesPresentationContext = true
        searchController.searchBar.placeholder = "搜索诗人、诗词"
        self.navigationItem.titleView = searchController.searchBar
        NSNotificationCenter.defaultCenter().addObserverForName("UserFontChangeNotif", object: nil, queue: NSOperationQueue.mainQueue()) { (_) in
            self.tableView.reloadData()
        }
    }

    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if searchController.searchBar.text?.characters.count == 0 {
            searchResultVC.view.hidden = false
            searchResultVC.searchText = nil
        } else {
            searchResultVC.searchText = searchController.searchBar.text
        }
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = true
        dispatch_async(dispatch_get_main_queue()) { 
            self.searchResultVC.view.hidden = false
        }
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchResultsController?.view.hidden = false
    }
    
    
    func willDismissSearchController(searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
        searchResultVC.searchText = nil
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
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SearchIndexCell
            if indexPath.section == 0 {
                 cell.poem = recPoem
            } else if indexPath.section == 2 {
                 cell.poet = recPoet
            } else {
                cell.format = recFormat
            }
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier("pcell", forIndexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            self.performSegueWithIdentifier("showpoem", sender: recPoem)
        } else if indexPath.section == 2 {
            self.performSegueWithIdentifier("showpoet", sender: recPoet)
        } else {
            self.performSegueWithIdentifier("showformat", sender: recFormat)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destinationViewController as? PoemDetailViewController {
            if let poem = sender as? Poem {
                vc.poemId = poem.id
            }
        }
        if let vc = segue.destinationViewController as? AuthorViewController {
            if segue.identifier == "showpoet" {
                let poet = sender as? Poet
                vc.poet = poet
            } else {
                let format = sender as? PoemFormat
                vc.format = format
            }
        }
    }

}
