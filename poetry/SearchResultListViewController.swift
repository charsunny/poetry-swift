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
import ChameleonFramework
import AlamofireImage

class SearchResultListViewController: UITableViewController {
    
    var resultList:[AnyObject] = []
    
    var searchType : SearchType = .poem

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0)
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "SearchResultCell", bundle : nil),forCellReuseIdentifier: "cell")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchResultCell
        
        let data = resultList[(indexPath as NSIndexPath).row]
        
        switch searchType {
        case .poem:
            cell.poem = data as? Poem
        case .poet:
            cell.poet = data as? Poet
        default:
            cell.format = data as? PoemFormat
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch searchType {
        case .poem:
            self.parent?.parent?.presentingViewController?.performSegue(withIdentifier: "showpoem", sender: resultList[(indexPath as NSIndexPath).row])
        case .poet:
            self.parent?.parent?.presentingViewController?.performSegue(withIdentifier: "showpoet", sender: resultList[(indexPath as NSIndexPath).row])
        default:
            self.parent?.parent?.presentingViewController?.performSegue(withIdentifier: "showformat", sender: resultList[(indexPath as NSIndexPath).row])
        }
    }

}

extension SearchResultListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string:"暂无搜索结果", attributes: TextAttributes().foregroundColor(UIColor.darkGray).font(UIFont.userFont(size:15)).alignment(.center))
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "theme\(searchType.rawValue+1)")?.af_imageScaled(to:CGSize(width: 120, height: 120)).af_imageRounded(withCornerRadius: 60)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -100
    }
}

