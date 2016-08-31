//
//  SearchResultListViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/8/27.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import TextAttributes

class SearchResultListViewController: UITableViewController {
    
    var resultList:[AnyObject] = []
    
    var searchType : SearchType = .Poem

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        tableView.tableFooterView = UIView()
        tableView.registerNib(UINib(nibName: "SearchResultCell", bundle : nil),forCellReuseIdentifier: "cell")
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SearchResultCell
        
        let data = resultList[indexPath.row]
        
        switch searchType {
        case .Poem:
            cell.poem = data as? Poem
        case .Poet:
            cell.poet = data as? Poet
        default:
            cell.format = data as? PoemFormat
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch searchType {
        case .Poem:
            self.parentViewController?.parentViewController?.presentingViewController?.performSegueWithIdentifier("showpoem", sender: resultList[indexPath.row])
        case .Poet:
            self.parentViewController?.parentViewController?.presentingViewController?.performSegueWithIdentifier("showpoet", sender: resultList[indexPath.row])
        default:
            self.parentViewController?.parentViewController?.presentingViewController?.performSegueWithIdentifier("showformat", sender: resultList[indexPath.row])
        }
    }

}

extension SearchResultListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string:"暂无搜索结果", attributes: TextAttributes().foregroundColor(UIColor.darkGrayColor()).font(UIFont.userFontWithSize(15)).alignment(.Center))
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "theme\(searchType.rawValue+1)")?.af_imageScaledToSize(CGSize(width: 120, height: 120)).af_imageWithRoundedCornerRadius(60)
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        return -100
    }
}

