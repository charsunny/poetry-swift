//
//  SecondViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/10.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import ChameleonFramework
import DZNEmptyDataSet
import TextAttributes
import PKHUD

class ExploreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var feedList:[Feed] = []
    
    let refreshControl = UIRefreshControl()
    
    var page = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(ExploreViewController.refresh), forControlEvents: .ValueChanged)
        tableView.sendSubviewToBack(refreshControl)
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func refresh() {
        Feed.GetFeedsAfter(feedList.first?.id ?? -1) { (list, error) in
            self.refreshControl.endRefreshing()
            if error == nil {
                if list.count > 0 {
                    self.feedList.insertContentsOf(list, at: 0)
                    self.tableView.reloadData()
                }
            } else {
                HUD.flash(.Label(String.ErrorString(error!)), delay: 1.0)
            }
        }
    }

    var isLoading = false
    var hasMore = true
    func loadData(page:Int = 0) {
        if isLoading {
            return
        }
        if page == 0 {
            HUD.show(.Progress)
        }
        isLoading = true
        Feed.GetFeeds(page) { (list, error) in
            HUD.hide()
            self.isLoading = false
            if page != self.page + 1 {
                return
            }
            if error == nil {
                if list.count > 0 {
                    self.page = page
                    self.feedList.appendContentsOf(list)
                    self.tableView.reloadData()
                } else {
                    self.hasMore = false
                }
            } else {
                HUD.flash(.Label(String.ErrorString(error!)), delay: 1.0)
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if hasMore && scrollView.contentOffset.y > 100 && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            self.loadData(self.page + 1)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! PoemCardCell
        cell.feed = feedList[indexPath.row]
        return cell
    }
    
    //var transitioner:CAVTransitioner?
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PoemDetailViewController {
            if let view = sender as? PoemTextView {
                vc.poem = view.poem
            }
        }
//        if let pvc = segue.destinationViewController as? ExploreAddViewController {
//            transitioner = CAVTransitioner()
//            if self.traitCollection.userInterfaceIdiom == .Pad {
//                 pvc.preferredContentSize = CGSize(width: 320, height: 200)
//            } else {
//                 pvc.preferredContentSize = CGSize(width: UIScreen.mainScreen().bounds.width - 40, height: 200)
//            }
//           
//            pvc.modalPresentationStyle = UIModalPresentationStyle.Custom
//            pvc.transitioningDelegate = transitioner
//        }
    }

}

extension ExploreViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string:"暂无分享内容", attributes: TextAttributes().foregroundColor(UIColor.darkGrayColor()).font(UIFont.userFontWithSize(15)).alignment(.Center))
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "theme4")?.af_imageScaledToSize(CGSize(width: 120, height: 120)).af_imageWithRoundedCornerRadius(60)
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return -40
    }
}
