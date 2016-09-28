//
//  PoemSearchViewController.swift
//  poetry
//
//  Created by sunsing on 9/2/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit

enum PoemSearchType {
    case poem
    case poet
    case dict
}

class PoemSearchViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    
    var poemSearchType:PoemSearchType = .poem
    
    var searchController:UISearchController!
    
    var poems:[Poem] = []
    
    var poets:[Poet] = []
    
    var explains:[(String, String)] = []
    
    var selectPoemAction:((Poem)->Void)?
    
    var selectPoetAction:((Poet)->Void)?
    
    var selectExplainAction:(((String, String))->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self;
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.definesPresentationContext = true
        searchController.searchBar.showsCancelButton = true
        searchController.searchBar.placeholder = poemSearchType == .poem ? "搜索诗词" : "搜索关键字"
        self.navigationItem.titleView = searchController.searchBar
        tableView.register(UINib(nibName: "SearchResultCell", bundle:nil), forCellReuseIdentifier: "cell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
        DispatchQueue.main.async { 
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
     // MARK: - search controller delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text.characters.count > 0 {
            if poemSearchType == .poem {
                self.poems = DataManager.manager.search(text)
            } else if poemSearchType == .poet {
                self.poets = DataManager.manager.searchAuthor(text)
            } else {
                self.explains = text.characters.reversed().map {
                    return (String($0),  DataManager.manager.explain($0) ?? "")
                }
            }
        } else {
            self.poems = []
            self.poets = []
            self.explains = []
        }
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if poemSearchType == .poem {
            return poems.count
        } else if poemSearchType == .poet {
            return poets.count
        }
        return explains.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchResultCell
        if poemSearchType == .poem {
            cell.poem = poems[indexPath.row]
        } else if poemSearchType == .poet {
            cell.poet = poets[indexPath.row]
        } else {
            cell.explain = explains[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if poemSearchType == .poem {
            selectPoemAction?(poems[indexPath.row])
        } else if poemSearchType == .poet {
            selectPoetAction?(poets[indexPath.row])
        } else {
            selectExplainAction?(explains[indexPath.row])
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
