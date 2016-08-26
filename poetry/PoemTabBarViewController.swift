//
//  PoemTabBarViewController.swift
//  poetry
//
//  Created by sunsing on 8/24/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import SwiftIconFont

class PoemTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = UIColor.flatRedColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let icons = ["spreadsheet", "magnifying-glass", "eye",  "chat",  "person"]
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var i:Int = 0
        for item in self.tabBar.items! {
            if i != 2 {
                item.icon(from: .Iconic, code: icons[i], imageSize: CGSizeMake(28, 28), ofSize: 20)
                item.imageInsets = UIEdgeInsetsMake(10, 0, -10, 0)
            } else {
                item.icon(from: .Iconic, code: icons[i], imageSize: CGSizeMake(34, 34), ofSize: 30)
                item.imageInsets = UIEdgeInsetsMake(8, 0, -8, 0)
            }
            
            i = i + 1
        }
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
