//
//  AuthorViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/19.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import TextAttributes
import SwiftIconFont

class AuthorViewController: UIViewController {
    
    @IBOutlet var headView: UIView!
    
    @IBOutlet var indicatorLeadingLayout: NSLayoutConstraint!
    
    @IBOutlet var buttonStackView: UIStackView!
    
    @IBOutlet weak var likeButton: UIBarButtonItem!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    lazy var controllers:[UIViewController] = {
        var list:[UIViewController] = []
        if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("authordetail") as? AuthorDetailViewController
        {
            vc.poet = self.poet
            list.append(vc)
        }
        if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("poemlist") as? AuthorPoemListViewController {
            vc.poet = self.poet
            list.append(vc)
        }
        if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("poemlist") as? AuthorPoemListViewController {
            vc.poet = self.poet
            list.append(vc)
        }
        list.append(self.storyboard!.instantiateViewControllerWithIdentifier("relatevc"))
        return list
    }()
    
    var pageController:UIPageViewController!
    
    var poems:[Poem] = []
    
    var poet:Poet!
    
    enum AuthorColumn : Int {
        case Hot = 0
        case Poem = 1
        case Intro = 2
        case Relative = 3
    }
    
    var column:AuthorColumn = .Hot
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = poet.name
        
        likeButton.icon(from: .Iconic, code: "heart", ofSize: 20)
        shareButton.icon(from: .Iconic, code: "share", ofSize: 20)
        
//        if let url = poet?.name.iconURL() {
//            headImageView.kf_setImageWithURL(NSURL(string:url)!, placeholderImage: UIImage(named:"defaulticon"))
//        }
//        
        for view in buttonStackView.arrangedSubviews where view is UIButton {
            let button = view as! UIButton
            button.addTarget(self, action: #selector(AuthorViewController.onClickButton(_:)), forControlEvents: .TouchUpInside)
        }
        
        dispatch_async(dispatch_get_main_queue()) { 
            self.poems = DataManager.manager.poemsByAuthor(self.poet.id)
        }
    }
    
    func onClickButton(btn:UIButton) {
        for view in buttonStackView.arrangedSubviews where view is UIButton {
            let button = view as! UIButton
            button.titleLabel?.font = UIFont.systemFontOfSize(15)
        }
        btn.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        if let index = buttonStackView.arrangedSubviews.indexOf(btn) {
            column = AuthorColumn(rawValue: index)!
            indicatorLeadingLayout.constant = btn.frame.width * CGFloat(index)
            UIView.animateWithDuration(0.2, animations: {
                self.headView.layoutIfNeeded()
            })
            pageController.setViewControllers([controllers[index]], direction: .Forward, animated: false, completion: nil)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destinationViewController as? UIPageViewController {
            self.pageController = vc
            vc.setViewControllers([controllers.first!], direction: .Forward, animated: false, completion: nil)
            vc.delegate = self
            vc.dataSource = self
        }
    }

}

extension AuthorViewController:UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let index = controllers.indexOf(pageViewController.viewControllers!.first!) {
            for view in buttonStackView.arrangedSubviews where view is UIButton {
                let button = view as! UIButton
                button.titleLabel?.font = UIFont.systemFontOfSize(15)
            }
            if let btn = buttonStackView.arrangedSubviews[index] as? UIButton {
                btn.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
                column = AuthorColumn(rawValue: index)!
                indicatorLeadingLayout.constant = btn.frame.width * CGFloat(index)
                UIView.animateWithDuration(0.2, animations: {
                    self.headView.layoutIfNeeded()
                })
            }
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index = controllers.indexOf(viewController)!
        if index == 3 {
            return nil
        }
        return controllers[index+1]
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let index = controllers.indexOf(viewController)!
        if index == 0 {
            return nil
        }
        return controllers[index-1]
    }
}
