//
//  DictViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/13.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

class DictViewController: UIViewController {
    
    var keyword = ""

    @IBOutlet var textView: UITextView!
    
    @IBOutlet var keyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyLabel.text = keyword
        keyLabel.font = UIFont.userFont(size:48)
        textView.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightThin)
        if let explain = DataManager.manager.explain(keyword.characters.first ?? " ") {
            textView.text = explain
        } else {
            textView.text = "暂无解释"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.contentOffset = CGPoint.zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
