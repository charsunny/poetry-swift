//
//  UserColumnViewController.swift
//  poetry
//
//  Created by sunsing on 9/2/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import TextAttributes
import StatusProvider
import SVProgressHUD

class ColumnItemCell : UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var imageView:UIImageView!
    
    override func awakeFromNib() {
        titleLabel.font = UIFont.userFont(size: 14)
        
    }
    
    var column:Column! {
        didSet {
            titleLabel.text = column.title
            descLabel.text = (column.type == 0 ) ? "\(column.count)首诗词" : "\(column.count)位诗人"
            if let url = URL(string: column.image) {
                imageView.af_setImage(withURL: url, placeholderImage: ((column.type == 0 ) ? UIImage(named: "col") : UIImage(named: "coll")))
            } else {
                imageView.image = ((column.type == 0 ) ? UIImage(named: "col") : UIImage(named: "coll"))
            }
        }
    }
    
}

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class UserColumnViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var isSelect = false
    
    var selType = 0 // 默认选择是诗集
    
    var selectAction: ((Column) -> Void)?
    
    var userId:Int?
    
    var colList:[Column] = []
    
    var colPage = -1
    
    var favPage = -1
    
    var favColList:[Column] = []
    
    var selIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.show(statusType: .loading)
        if (selIndex == 0 && hasMoreCol) {
            self.loadData(self.colPage + 1)
        }
        if (selIndex == 1 && hasMoreFav) {
            self.loadData(self.favPage + 1)
        }
        if isSelect {
            self.navigationItem.title = "选择专辑"
            self.navigationItem.titleView = nil
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ColumnAddSuccessNotif"), object: nil, queue: OperationQueue.main) { (notif) in
            if let col = notif.object as? Column {
                self.colList.append(col)
                self.collectionView?.reloadData()
            }
        }
    }
  
    @IBAction func segSelChanged(_ sender: UISegmentedControl) {
        selIndex = sender.selectedSegmentIndex
        self.collectionView?.reloadData()
    }
    
    var hasMoreCol = true
    var hasMoreFav = true
    
    func loadData(_ page:Int = 0) {
        let index = selIndex
        if selIndex == 0 {
            Column.GetUserColumnList(page, uid: userId ?? User.LoginUser?.id ?? 0, finish: { (list, error) in
                self.hide(statusType: .loading)
                if error == nil {
                    if page == self.colPage + 1 && self.selIndex == index {
                        if list.count > 0 {
                            if self.isSelect {
                                self.colList.append(contentsOf: list.filter{$0.type == self.selType})
                            } else {
                                self.colList.append(contentsOf: list)
                            }
                            self.colPage = page
                            self.collectionView?.reloadData()
                        } else {
                            self.hasMoreCol = false
                            if self.colList.count == 0 {
                                self.show(statusType: .empty(action:nil))
                            }
                        }
                    }
                } else {
                    
                }
            })
        } else {
            Column.GetUserFavColumnList(page, uid: userId ?? User.LoginUser?.id ?? 0, finish: { (list, error) in
                self.hide(statusType: .loading)
                if error == nil {
                    if page == self.favPage + 1 && self.selIndex == index {
                        if list.count > 0 {
                            self.favColList.append(contentsOf: list)
                            self.favPage = page
                            self.collectionView?.reloadData()
                        } else {
                            self.hasMoreFav = false
                            if self.favColList.count == 0 {
                                self.show(statusType: .empty(action:nil))
                            }
                        }
                    }
                } else {
                }
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = self.view.frame.width
        let count = Int(width/96)
        let margin = (width - CGFloat(count * 96))/CGFloat(count + 1)
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: margin, bottom: 20, right: margin)
        if collectionView?.contentSize.height < collectionView?.frame.height {
            collectionView?.contentSize = CGSize(width: collectionView!.frame.width, height: collectionView!.frame.height + 1)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if  scrollView.contentOffset.y > 100 && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            if (selIndex == 0 && hasMoreCol) {
                self.loadData(self.colPage + 1)
            }
            if (selIndex == 1 && hasMoreFav) {
                self.loadData(self.favPage + 1)
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selIndex == 0 {
            return colList.count
        }
        return favColList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ColumnItemCell
        if selIndex == 0 {
            if indexPath.item == colList.count {
                let acell = collectionView.dequeueReusableCell(withReuseIdentifier: "acell", for: indexPath)
                return acell
            }
            cell.column = colList[indexPath.item]
        } else {
            cell.column = favColList[indexPath.item]
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if isSelect {
            if selIndex == 0 {
                selectAction?(colList[indexPath.item])
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                selectAction?(favColList[indexPath.item])
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if isSelect && identifier == "showdetail" {
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? ColumnDetailViewController {
            let indexPath = collectionView?.indexPath(for: sender as! UICollectionViewCell)
            if selIndex == 0 {
                vc.column = colList[indexPath!.item]
            } else {
                vc.column = favColList[indexPath!.item]
            }
        }
    }

}

extension UserColumnViewController: StatusProvider {
    
    var emptyView: EmptyStatusDisplaying?{
        let image = UIImage(named: "theme3")?.af_imageScaled(to:CGSize(width: 120, height: 120)).af_imageRounded(withCornerRadius:60)
        return EmptyStatusView(title: "没有数据", caption: "专辑列表为空", image: image, actionTitle: nil)
    }
}

