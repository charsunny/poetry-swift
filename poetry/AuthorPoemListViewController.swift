//
//  AuthorPoemListViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/8/24.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

class AuthorPoemListViewController: UITableViewController {
    
    var poet:Poet!
    var poems:[Poem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            self.poems = DataManager.manager.poemsByAuthor(self.poet.id)
            dispatch_async(dispatch_get_main_queue()){
                self.tableView.reloadData()
            }
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.poems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let poem = poems[indexPath.row]
        cell.textLabel?.text = poem.name
        cell.textLabel?.font = UIFont.userFontWithSize(16)
        cell.detailTextLabel?.font = UIFont.userFontWithSize(14)
        if poem.content?.characters.count > 40 {
            cell.detailTextLabel?.text = ((poem.content as NSString?)?.substringToIndex(40).stringByReplacingOccurrencesOfString("\r\n", withString: "") ?? "") + "..."
        } else {
            cell.detailTextLabel?.text = poem.content?.stringByReplacingOccurrencesOfString("\r\n", withString: "")
        }
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let poemVC = segue.destinationViewController as? PoemDetailViewController {
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            poemVC.poem = poems[indexPath.row]
        }
    }

}
