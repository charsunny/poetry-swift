//
//  SecondViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/10.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import ChameleonFramework
import StatusProvider
import TextAttributes
import MWPhotoBrowser

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
        tableView.estimatedRowHeight = 420
        tableView.rowHeight = UITableViewAutomaticDimension
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
                HUD.flash(.error(error!.localizedDescription), delay: 1.0)
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
            self.show(statusType: .loading)
        }
        isLoading = true
        Feed.GetFeeds(page) { (list, error) in
            self.hide(statusType: .loading)
            self.isLoading = false
            if page != self.page + 1 {
                return
            }
            if error == nil {
                if list.count > 0 {
                    if page == self.page + 1 {
                        self.page = page
                        self.feedList.append(contentsOf: list)
                        self.tableView.reloadData()
                    }
                } else {
                    self.hasMore = false
                    if self.feedList.count == 0 {
                        self.show(statusType: .empty(action:nil))
                    }
                }
            } else {
                /*if page == 0 {
                    self.show(statusType: .error(error: error, retry: {
                        self.loadData(page)
                        self.show(statusType: .loading)
                    }))
                }*/
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
    
    var selFeed:Feed?
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PoemExploreCell
        cell.feed = feedList[(indexPath as NSIndexPath).row]
        cell.showPoemAction = {
            if let poemVC = UIStoryboard(name:"Recommend", bundle: nil).instantiateViewController(withIdentifier: "poemvc") as? PoemDetailViewController {
                poemVC.poem = $0
                self.navigationController?.pushViewController(poemVC, animated: true)
            }
        }
        cell.showUserAction = {
            if let userVC = UIStoryboard(name:"User", bundle: nil).instantiateViewController(withIdentifier: "uservc") as? UserViewController {
                userVC.user = $0
                self.navigationController?.pushViewController(userVC, animated: true)
            }
        }
        cell.commentAction = {
            if let commentVC = UIStoryboard(name:"Recommend", bundle: nil).instantiateViewController(withIdentifier: "commentvc") as? PoemCommentViewController {
                commentVC.commentType = .feed
                commentVC.feed = $0
                self.navigationController?.pushViewController(commentVC, animated: true)
            }
        }
        cell.shareAction = {
            if let shareNavVC = UIStoryboard(name:"Explore", bundle: nil).instantiateViewController(withIdentifier: "sharenavvc") as? UINavigationController {
                if let shareVC = shareNavVC.viewControllers.first as? ExploreAddViewController {
                    shareVC.poem = $0.poem
                }
                self.present(shareNavVC, animated: true, completion: nil)
            }
        }
        cell.showPicAction = {
            self.selFeed = $0
            let broserVC = MWPhotoBrowser(delegate: self)!
            self.navigationController?.pushViewController(broserVC, animated: true)
        }
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

extension ExploreViewController: MWPhotoBrowserDelegate, StatusProvider {
    
    var emptyView: EmptyStatusDisplaying?{
        let image = UIImage(named: "theme4")?.af_imageScaled(to:CGSize(width: 120, height: 120)).af_imageRounded(withCornerRadius:60)
        return EmptyStatusView(title: "没有分享", caption: "分享列表为空", image: image, actionTitle: nil)
    }
    
    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return 1
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        if let url = URL(string: selFeed?.picture ?? "") {
            return MWPhoto(url: url)
        }
        return nil
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, titleForPhotoAt index: UInt) -> String! {
        return selFeed?.content
    }
}
