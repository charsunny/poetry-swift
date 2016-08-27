//
//  SearchResultViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/8/27.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

class SearchResultViewController: UIViewController {

    @IBOutlet weak var leadingLayout: NSLayoutConstraint!
    
    @IBOutlet weak var buttonGroup: UIStackView!
    
    var pageViewController: UIPageViewController!
    
    lazy var resultVCS:[SearchResultListViewController] = {
        var list:[SearchResultListViewController] = []
        let vc1 = self.storyboard!.instantiateViewControllerWithIdentifier("searchlist") as! SearchResultListViewController
        list.append(vc1)
        let vc2 = self.storyboard!.instantiateViewControllerWithIdentifier("searchlist") as! SearchResultListViewController
        list.append(vc2)
        let vc3 = self.storyboard!.instantiateViewControllerWithIdentifier("searchlist") as! SearchResultListViewController
        list.append(vc3)
        return list
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onTapButton(sender: UIButton) {
        if let index = buttonGroup.arrangedSubviews.indexOf(sender) {
            leadingLayout.constant = CGFloat(index) * sender.frame.size.width
            pageViewController.setViewControllers([resultVCS[index]], direction: .Forward, animated: false, completion: nil)
        }
        UIView.animateWithDuration(0.2) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destinationViewController as? UIPageViewController {
            pageViewController = vc
            pageViewController.delegate = self
            pageViewController.dataSource = self
            pageViewController.setViewControllers([resultVCS.first!], direction: .Forward, animated: false, completion: nil)
        }
    }
}

extension SearchResultViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let index = resultVCS.indexOf(viewController as! SearchResultListViewController) {
            if index > 1 {
                return nil
            }
            return resultVCS[index + 1]
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let index = resultVCS.indexOf(viewController as! SearchResultListViewController) {
            if index < 1 {
                return nil
            }
            return resultVCS[index - 1]
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let index = resultVCS.indexOf(pageViewController.viewControllers?.first! as! SearchResultListViewController) {
           leadingLayout.constant = CGFloat(index) * self.view.frame.size.width / 3
            UIView.animateWithDuration(0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
