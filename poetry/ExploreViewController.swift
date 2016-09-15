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

class ExploreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var feedList:[Feed] = []
    
    let refreshControl = UIRefreshControl()
    
    var page = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "PoemExploreCell", bundle:nil), forCellReuseIdentifier: "cell")
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(ExploreViewController.refresh), for: .valueChanged)
        tableView.sendSubview(toBack: refreshControl)
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        loadData()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserFontChangeNotif"), object: nil, queue: OperationQueue.main) { (_) in
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func refresh() {
        Feed.GetFeedsAfter(feedList.first?.id ?? -1) { (list, error) in
            self.refreshControl.endRefreshing()
            if error == nil {
                if list.count > 0 {
                    self.feedList.insert(contentsOf: list, at: 0)
                    self.tableView.reloadData()
                }
            } else {
                //HUD.flash(.label(String.ErrorString(error!)), delay: 1.0)
            }
        }
    }

    var isLoading = false
    var hasMore = true
    func loadData(_ page:Int = 0) {
        if isLoading {
            return
        }
        if page == 0 {
            //HUD.show(.progress)
        }
        isLoading = true
        Feed.GetFeeds(page) { (list, error) in
            //HUD.hide()
            self.isLoading = false
            if page != self.page + 1 {
                return
            }
            if error == nil {
                if list.count > 0 {
                    self.page = page
                    self.feedList.append(contentsOf: list)
                    self.tableView.reloadData()
                } else {
                    self.hasMore = false
                }
            } else {
               // HUD.flash(.label(String.ErrorString(error!)), delay: 1.0)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if hasMore && scrollView.contentOffset.y > 100 && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            self.loadData(self.page + 1)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PoemExploreCell
        cell.viewController = self
        cell.feed = feedList[(indexPath as NSIndexPath).row]
        return cell
    }
    
    //var transitioner:CAVTransitioner?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string:"暂无分享内容", attributes: TextAttributes().foregroundColor(UIColor.darkGray).font(UIFont.userFont(size:15)).alignment(.center))
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "theme4")?.af_imageScaled(to:CGSize(width: 120, height: 120)).af_imageRounded(withCornerRadius:60)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -40
    }
}
