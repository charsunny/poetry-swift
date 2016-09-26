//
//  UserNotifViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/8/26.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import StatusProvider
import TextAttributes

class UserNotifViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserFontChangeNotif"), object: nil, queue: OperationQueue.main) { (_) in
            self.tableView.reloadData()
        }
        self.show(statusType: .empty(action: nil))
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

}

extension UserNotifViewController: StatusProvider {
    
    var emptyView: EmptyStatusDisplaying?{
        let image = UIImage(named: "theme6")?.af_imageScaled(to:CGSize(width: 120, height: 120)).af_imageRounded(withCornerRadius:60)
        return EmptyStatusView(title: "没有动态", caption: "暂无相关动态", image: image, actionTitle: nil)
    }
}
