//
//  SecondViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/10.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import ChameleonFramework
import Alamofire

class ExploreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    var poems:[NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    var currentPoem:Int = 0

    func loadData(page:Int = 1) {
        Alamofire.request(.GET, "http://ansinlee.com/feeds?page=\(page)").responseJSON {
            guard let data = $0.result.value else {
                return
            }
            if let json = data as? [NSDictionary] {
                self.poems.appendContentsOf(json)
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        return cell
    }
    
    var transitioner:CAVTransitioner?
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? PoemDetailViewController {
            if let view = sender as? PoemTextView {
                vc.poem = view.poem
            }
        }
        if let pvc = segue.destinationViewController as? LikeViewController {
            transitioner = CAVTransitioner()
            if self.traitCollection.userInterfaceIdiom == .Pad {
                 pvc.preferredContentSize = CGSize(width: 320, height: 200)
            } else {
                 pvc.preferredContentSize = CGSize(width: UIScreen.mainScreen().bounds.width - 40, height: 200)
            }
           
            pvc.modalPresentationStyle = UIModalPresentationStyle.Custom
            pvc.transitioningDelegate = transitioner
        }
    }

}

