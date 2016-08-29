//
//  UserViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/10.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import AlamofireImage

class UserViewController: UITableViewController {
    
    var user : User?

    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    
    @IBOutlet weak var favCountLabel: UILabel!
    
    @IBOutlet weak var followCountLabel: UILabel!
    
    @IBOutlet weak var followeeCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserverForName("LoginSuccess", object: nil, queue: NSOperationQueue.mainQueue()) { (_) in
            self.showUserInfo()
        }
        headerView.backgroundColor = UIColor.flatRedColor()
        showUserInfo()
    }
    
    func showUserInfo() {
        var userinfo:User? = self.user
        if userinfo == nil {
            userinfo = User.LoginUser
        }
        if let user = userinfo  {
            avatarImageView.af_setImageWithURL(NSURL(string: user.avatar) ?? NSURL(), placeholderImage: UIImage(named: "defaulticon"))
            nameLabel.text = user.nick
            likeCountLabel.text = "\(user.likeCount)"
            favCountLabel.text = "\(user.columnCount)"
            followCountLabel.text = "\(user.followCount)"
            followeeCountLabel.text = "\(user.followeeCount)"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.hidden = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.hidden = false
    }
    

    override func viewDidLayoutSubviews() {
        let offset = tableView.contentOffset
        headerView.frame = CGRect(x: 0, y: offset.y, width: headerView.frame.width, height: 230 - offset.y)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 11
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 424
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        return cell
    }
    
}
