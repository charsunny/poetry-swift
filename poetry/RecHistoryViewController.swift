//
//  RecHistoryViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/19.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import Alamofire

class RecHistoryCell : UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var headImageView: UIImageView!
    
    @IBOutlet var descLabel: UILabel!
    
    override func awakeFromNib() {
        titleLabel.font = UIFont.userFont(size:15)
        titleLabel.textColor = UIColor.darkGray
        descLabel.font = UIFont.userFont(size:17)
    }
    
    var data:Recommend! {
        didSet {
            if data == nil {
                return
            }
            titleLabel.text = data.time
            descLabel.text = data.desc
            headImageView.image = UIImage.imageWithString(data.title , size: CGSize(width: 100, height: 100))
        }
    }
    
}

class RecHistoryViewController: UITableViewController {
    
    var page = -1

    var recs:[Recommend] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData(0)
    }
    
    var hasMore = true
    var isLoading = false
    func loadData(_ page:Int, isReload:Bool = false) {
        if isLoading {
            return
        }
        isLoading = true
        Recommend.GetRecList(page) { (list, error) in
            self.isLoading = false
            self.refreshControl?.endRefreshing()
            if error == nil {
                if isReload {
                    self.recs = list
                } else {
                    if page == self.page + 1 {
                        if list.count == 0 {
                            self.hasMore = false
                        }
                        self.recs.append(contentsOf: list)
                        self.page = page + 1
                    }
                }
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func refresh(_ sender: AnyObject) {
        //loadData(0, isReload: true)
        self.refreshControl?.endRefreshing()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if hasMore && scrollView.contentOffset.y > 100 && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            self.loadData(self.page + 1)
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecHistoryCell

        cell.data = recs[indexPath.row]

        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? RecommendViewController {
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
            vc.recInfo = recs[indexPath.row]
        }
    }

}
