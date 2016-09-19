//
//  SearchViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/10.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height - 64 - 50 - 180
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if (indexPath as NSIndexPath).row == 0 {
            return false
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchIndexCell
        cell.poem = recPoem
        cell.poet = recPoet
        cell.format = recFormat
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath as NSIndexPath).section == 0 {
            self.performSegue(withIdentifier: "showpoem", sender: recPoem)
        } else if (indexPath as NSIndexPath).section == 2 {
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
