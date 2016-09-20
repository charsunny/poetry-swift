//
//  ColumnDetailViewController.swift
//  poetry
//
//  Created by sunsing on 9/20/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import AlamofireImage
import TextAttributes
import DZNEmptyDataSet
import SVProgressHUD

class ColumnDetailViewController: UITableViewController {
    
    var columnId : Int = 0
    
    var column:Column?

    @IBOutlet weak var headView: UIView!
    
    @IBOutlet weak var bgImageView: UIImageView!
    
    @IBOutlet weak var columnImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var userButtons: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName:"SearchResultCell", bundle:nil), forCellReuseIdentifier: "cell")
        tableView.rowHeight = 80
        titleLabel.font = UIFont.userFont(size: 18)
        descLabel.font = UIFont.userFont(size: 14)
        if let column = column {
            updateHeadView()
            self.columnId = column.id
        }
        loadColumnData()
    }
    
    func loadColumnData() {
        Column.GetDetail(self.columnId) { (col, error) in
            if let col = col {
                self.column = col
                self.updateHeadView()
                self.tableView.reloadData()
            }
        }
    }
    
    func updateHeadView() {
        if let column = column {
            titleLabel.text = column.title
            descLabel.text = column.desc
            if let url = URL(string: column.image) {
                columnImageView.af_setImage(withURL: url, placeholderImage: ((column.type == 0 ) ? UIImage(named: "col") : UIImage(named: "coll")))
            } else {
                columnImageView.image = ((column.type == 0 ) ? UIImage(named: "col") : UIImage(named: "coll"))
            }
            (userButtons.arrangedSubviews.first as? UIButton)?.setTitle("\(column.commentCount)", for: .normal)
            let likeButton = userButtons.arrangedSubviews[1] as! UIButton
            likeButton.setTitle("\(column.likeCount)", for: UIControlState())
            likeButton.setImage(UIImage(named: column.isFav ? "heart" : "hert") , for: UIControlState())
            likeButton.tintColor = column.isFav ? UIColor.flatRed() : UIColor.white
            if let userButton = userButtons.arrangedSubviews.last as? UIButton {
                userButton.setTitle((column.user?.nick ?? ""), for: .normal)
                if let url = URL(string:column.user?.avatar ?? "") {
                    let imageFilter = ScaledToSizeWithRoundedCornersFilter(size: CGSize(width:20, height:20), radius: 10)
                    UIImageView.af_sharedImageDownloader.download(URLRequest(url:url), filter:imageFilter, completion: { (res) in
                        switch res.result {
                        case .success(let value):
                            userButton.setImage(value.af_imageScaled(to: CGSize(width: 20, height: 20)).af_imageRoundedIntoCircle(), for: .normal)
                        case .failure:
                            userButton.setImage(UIImage(named:"poet")?.af_imageScaled(to: CGSize(width: 20, height: 20)).af_imageRoundedIntoCircle(), for: .normal)
                        }
                    })
                } else {
                    userButton.setImage(UIImage(named:"poet")?.af_imageScaled(to: CGSize(width: 30, height: 30)).af_imageRoundedIntoCircle(), for: .normal)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if tableView.contentOffset.y + 64 < 0 {
            headView.frame = CGRect(x: 0, y: tableView.contentOffset.y + 64 , width: headView.frame.size.width, height: 160 - 64 - tableView.contentOffset.y)
        } else {
            headView.frame = CGRect(x: 0, y:0, width: headView.frame.size.width, height: 160)
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let column = column {
            return column.type == 0 ? (column.poems?.count ?? 0) : (column.poets?.count ?? 0)
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchResultCell

        if let column = column {
            if column.type == 0 {
                cell.poem = column.poems![indexPath.row]
            } else {
                cell.poet = column.poets![indexPath.row]
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let column = column {
            if column.type == 0 {
                let poem = column.poems![indexPath.row]
                self.performSegue(withIdentifier: "showpoem", sender: poem)
            } else {
                let poet = column.poets![indexPath.row]
                self.performSegue(withIdentifier: "showpoet", sender: poet)
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showuser" && column?.user?.id == User.LoginUser?.id {
            return false
        }
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? PoemDetailViewController {
            vc.poem = sender as? Poem
        }
        if let vc = segue.destination as? AuthorViewController {
            vc.poet = sender as? Poet
        }
    }
}

extension ColumnDetailViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string:"暂无收藏内容", attributes: TextAttributes().foregroundColor(UIColor.darkGray).font(UIFont.userFont(size:15)).alignment(.center))
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "theme6")?.af_imageScaled(to:CGSize(width: 120, height: 120)).af_imageRounded(withCornerRadius:60)
    }
    
}

