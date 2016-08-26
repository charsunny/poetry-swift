//
//  MessageViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/8/26.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    @IBOutlet weak var liveButton: UIButton!
    
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var leadingLayout: NSLayoutConstraint!
    
    var pageViewController: UIPageViewController!
    
    lazy var userNotifViewController : UserNotifViewController = {
        let tmp = self.storyboard!.instantiateViewControllerWithIdentifier("usernotif") as! UserNotifViewController
        return tmp
    }()
    
    lazy var chatListViewController : ChatListViewController = {
        let tmp = self.storyboard!.instantiateViewControllerWithIdentifier("chatlist") as! ChatListViewController
        return tmp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onTapButton(sender: UIButton) {
        
        if sender == liveButton {
            pageViewController.setViewControllers([userNotifViewController], direction: .Forward, animated: false, completion: nil)
            leadingLayout.constant = 0
        } else {
            pageViewController.setViewControllers([chatListViewController], direction: .Forward, animated: false, completion: nil)
            leadingLayout.constant = sender.frame.width
        }
        
        UIView.animateWithDuration(0.2) { 
            self.view.layoutIfNeeded()
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if viewController == userNotifViewController {
            return chatListViewController
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if viewController == chatListViewController {
            return userNotifViewController
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if pageViewController.viewControllers?.first == chatListViewController {
            leadingLayout.constant = liveButton.frame.width
        } else if pageViewController.viewControllers?.first == userNotifViewController {
            leadingLayout.constant = 0
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
            pageViewController.setViewControllers([userNotifViewController], direction: .Forward, animated: false, completion: nil)
        }
    }

}
