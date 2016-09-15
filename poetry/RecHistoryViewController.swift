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
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var descLabel: UILabel!
    
    override func awakeFromNib() {
        nameLabel.font = UIFont.userFont(size:64)
        descLabel.font = UIFont.userFont(size:17)
    }
    
    var data:NSDictionary! {
        didSet {
            if data == nil {
                return
            }
            nameLabel.text = data["Title"] as? String ?? ""
            descLabel.text = data["Desc"] as? String ?? ""
        }
    }
    
}

class RecHistoryViewController: UITableViewController {
    
    var page = 0

    var recs:[NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData(1)
    }
    
    var isLoading = false
    func loadData(_ page:Int, isReload:Bool = false) {
        if isLoading {
            return
        }
        isLoading = true
        /*Alamofire.request(.get, "\(ServerURL)his", parameters: ["type":"json", "page":page, "count":30]).responseJSON {
            self.isLoading = false
            self.refreshControl?.endRefreshing()
            guard let data = $0.result.value else {
                return
            }
            if let json = data as? [NSDictionary] {
                if isReload {
                    self.recs = json
                } else {
                    if page == self.page + 1 {
                        self.recs.append(contentsOf: json)
                        self.page = page + 1
                    }
                }
                self.tableView.reloadData()
            }
        }*/
    }

    @IBAction func refresh(_ sender: AnyObject) {
        loadData(1, isReload: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return recs.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return recs[section]["Time"] as? String ?? ""
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecHistoryCell

        cell.data = recs[(indexPath as NSIndexPath).section]

        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? RecommendViewController {
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
            vc.recInfo = recs[(indexPath as NSIndexPath).section]
        }
    }

}
