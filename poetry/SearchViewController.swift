//
//  SearchViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/10.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

class PoetSimpleView: UIView {
    
    override func awakeFromNib() {
        self.nameLabel.font = UIFont.userFont(size: 13)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PoetSimpleView.onClick)))
    }
    
    @IBOutlet var imageView:UIImageView!
    @IBOutlet var nameLabel:UILabel!
    
    func onClick() {
        if let poetVC = UIStoryboard(name: "Recommend", bundle: nil).instantiateViewController(withIdentifier: "poetvc") as? AuthorViewController {
            poetVC.poet = poet
            self.vc?.navigationController?.pushViewController(poetVC, animated: true)
        }
    }
    
    var poet:Poet! {
        didSet {
            nameLabel.text = poet.name
            if let url = URL(string:poet.name.iconURL()) {
                imageView.af_setImage(withURL:url, placeholderImage: UIImage.imageWithString(poet.name, size: CGSize(width: 80, height: 80)))
            } else {
                imageView.image = UIImage.imageWithString(poet.name, size: CGSize(width: 80, height: 80))
            }
        }
    }
    
    weak var vc:UIViewController?
}

class SearchViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {

    var searchController:UISearchController!
    
    lazy var searchResultVC:SearchResultViewController = {
        let tmpVC = self.storyboard!.instantiateViewController(withIdentifier: "searchresult") as! SearchResultViewController
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
        let calendaer = Calendar(identifier: Calendar.Identifier.gregorian)
        return abs((calendaer as NSCalendar?)?.components(.day, from: Date(), to: Date.init(timeIntervalSince1970: 0), options: .wrapComponents).day ?? 1)
    } ()
    
    var hotPoets = ["李白", "杜甫", "苏轼", "白居易", "李清照", "李商隐", "杜牧", "柳永"]
    
    @IBOutlet var hotPoetView:[PoetSimpleView]!
    
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
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserFontChangeNotif"), object: nil, queue: OperationQueue.main) { (_) in
            self.tableView.reloadData()
        }
        hotPoetView.forEach { (view) in
            let name = hotPoets[hotPoetView.index(of: view)!]
            view.vc = self
            view.poet = DataManager.manager.poetByName(name).first
        }
    }

    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text?.characters.count == 0 {
            searchResultVC.view.isHidden = false
            searchResultVC.searchText = nil
        } else {
            searchResultVC.searchText = searchController.searchBar.text
        }
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = true
        DispatchQueue.main.async { 
            self.searchResultVC.view.isHidden = false
        }
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
    }
    
    
    func willDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
        searchResultVC.searchText = nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchIndexCell
        if indexPath.row == 0 {
            cell.poem = recPoem
        } else if indexPath.row == 2 {
            cell.poet = recPoet
        } else {
            cell.format = recFormat
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "showpoem", sender: recPoem)
        } else if indexPath.row == 2 {
            self.performSegue(withIdentifier: "showpoet", sender: recPoet)
        } else {
            self.performSegue(withIdentifier: "showformat", sender: recFormat)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? PoemDetailViewController {
            if let poem = sender as? Poem {
                vc.poemId = poem.id
            }
        }
        if let vc = segue.destination as? AuthorViewController {
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
