//
//  PoemWonderViewController.swift
//  poetry
//
//  Created by sunsing on 9/1/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit

class PoemWonderViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    @IBOutlet var titleView: UIView!
    
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var authorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        self.titleView.alpha = 0
        self.titleLabel.font = UIFont.userFont(size:18)
        self.authorLabel.font = UIFont.userFont(size:13)
        if let poemVC = UIStoryboard(name: "Recommend", bundle: nil).instantiateViewController(withIdentifier: "poemvc") as? PoemDetailViewController {
            poemVC.poem = DataManager.manager.poemByRowId(Int(arc4random())%50000 + 1)
            self.titleLabel.text = poemVC.poem?.title
            self.authorLabel.text = poemVC.poem?.poet?.name ?? ""
            self.setViewControllers([poemVC], direction: .forward, animated:false, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.titleView.frame = CGRect(x: 30, y: 7, width: UIScreen.main.bounds.width - 88, height: 30)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let poemVC = UIStoryboard(name: "Recommend", bundle: nil).instantiateViewController(withIdentifier: "poemvc") as? PoemDetailViewController {
            poemVC.poem = DataManager.manager.poemByRowId(Int(arc4random())%50000 + 1)
            return poemVC
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let poemVC = pageViewController.viewControllers?.first as? PoemDetailViewController {
            self.titleLabel.text = poemVC.poem?.title
            self.authorLabel.text = poemVC.poem?.poet?.name ?? ""
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
