//
//  AuthorPoemListViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/8/24.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

class AuthorPoemListViewController: UITableViewController {
    
    var poet:Poet?
    var format:PoemFormat?
    var poems:[Poem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .default).async {
            if let poet = self.poet {
                self.poems = DataManager.manager.poemsByAuthor(poet.id)
            } else if let format = self.format {
                self.poems = DataManager.manager.poemsByFormat(format.id)
            }
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.poems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let poem = poems[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = poem.title
        cell.textLabel?.font = UIFont.userFont(size:16)
        cell.detailTextLabel?.font = UIFont.userFont(size:14)
        if poem.content.characters.count > 40 {
            cell.detailTextLabel?.text = ((poem.content as NSString?)?.substring(to: 40).replacingOccurrences(of: "\r\n", with: "") ?? "") + "..."
        } else {
            cell.detailTextLabel?.text = poem.content.replacingOccurrences(of: "\r\n", with: "")
        }
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let poemVC = segue.destination as? PoemDetailViewController {
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
            poemVC.poemId = poems[(indexPath as NSIndexPath).row].id
        }
    }

}
