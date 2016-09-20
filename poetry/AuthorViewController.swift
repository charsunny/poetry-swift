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
    
    lazy var controllers:[UIViewController] = {
        var list:[UIViewController] = []
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "authordetail") as? AuthorDetailViewController
        {
            vc.poet = self.poet
            vc.format = self.format
            list.append(vc)
        }
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "poemlist") as? AuthorPoemListViewController {
            vc.poet = self.poet
            vc.format = self.format
            list.append(vc)
        }
        list.append(self.storyboard!.instantiateViewController(withIdentifier: "relatevc"))
        return list
    }()
    
    var pageController:UIPageViewController!
    
    var poet:Poet?
    
    var format:PoemFormat?
    
    enum AuthorColumn : Int {
        case intro = 0
        case poem = 1
        case relative = 2
    }
    
    var column:AuthorColumn = .intro
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let poet = poet {
            self.title = poet.name
        } else if let format = format {
            self.title = format.name
        }

        for view in buttonStackView.arrangedSubviews where view is UIButton {
            let button = view as! UIButton
            button.addTarget(self, action: #selector(AuthorViewController.onClickButton(_:)), for: .touchUpInside)
        }
    }
    
    func onClickButton(_ btn:UIButton) {
        for view in buttonStackView.arrangedSubviews where view is UIButton {
            let button = view as! UIButton
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        }
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        if let index = buttonStackView.arrangedSubviews.index(of: btn) {
            column = AuthorColumn(rawValue: index)!
            indicatorLeadingLayout.constant = btn.frame.width * CGFloat(index)
            UIView.animate(withDuration: 0.2, animations: {
                self.headView.layoutIfNeeded()
            })
            pageController.setViewControllers([controllers[index]], direction: .forward, animated: false, completion: nil)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? UIPageViewController {
            self.pageController = vc
            vc.setViewControllers([controllers.first!], direction: .forward, animated: false, completion: nil)
            vc.delegate = self
            vc.dataSource = self
        }
        if let vc = segue.destination as? UserColumnViewController {
            vc.isSelect = true
            vc.selType = 1
            vc.selectAction = {
                Column.UpdateItem($0.id, pid: self.poet?.id ?? 0, finish: { (delete, err) in
                    if err != nil {
                        HUD.flash(.error("添加收藏失败"), delay: 3.0)
                    } else {
                        HUD.flash(.success(delete ? "删除成功" : "添加收藏成功"), delay: 3.0)
                    }
                })
            }
        }
    }

}

extension AuthorViewController:UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let index = controllers.index(of: pageViewController.viewControllers!.first!) {
            for view in buttonStackView.arrangedSubviews where view is UIButton {
                let button = view as! UIButton
                button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            }
            if let btn = buttonStackView.arrangedSubviews[index] as? UIButton {
                btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
                column = AuthorColumn(rawValue: index)!
                indicatorLeadingLayout.constant = btn.frame.width * CGFloat(index)
                UIView.animate(withDuration: 0.2, animations: {
                    self.headView.layoutIfNeeded()
                })
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = controllers.index(of: viewController)!
        if index == 2 {
            return nil
        }
        return controllers[index+1]
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = controllers.index(of: viewController)!
        if index == 0 {
            return nil
        }
        return controllers[index-1]
    }
}
