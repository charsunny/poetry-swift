//
//  SearchResultViewController.swift
//  poetry
//
//  Created by Xi Sun on 16/8/27.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

enum SearchType : Int {
    case poem = 0
    case poet = 1
    case format = 2
}

class SearchResultViewController: UIViewController {

    @IBOutlet weak var leadingLayout: NSLayoutConstraint!
    
    @IBOutlet weak var buttonGroup: UIStackView!
    
    var searchText:String? {
        didSet {
            searchWithText()
        }
    }
    
    var pageViewController: UIPageViewController!
    
    lazy var resultVCS:[SearchResultListViewController] = {
        var list:[SearchResultListViewController] = []
        let vc1 = self.storyboard!.instantiateViewController(withIdentifier: "searchlist") as! SearchResultListViewController
        vc1.searchType = .poem
        list.append(vc1)
        let vc2 = self.storyboard!.instantiateViewController(withIdentifier: "searchlist") as! SearchResultListViewController
        vc2.searchType = .poet
        list.append(vc2)
        let vc3 = self.storyboard!.instantiateViewController(withIdentifier: "searchlist") as! SearchResultListViewController
        vc3.searchType = .format
        list.append(vc3)
        return list
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func searchWithText() {
        if let vc = pageViewController.viewControllers?.first as? SearchResultListViewController {
            if let searchText = searchText {
                switch vc.searchType {
                case .poem:
                    vc.resultList = DataManager.manager.search(searchText)
                case .poet:
                    vc.resultList = DataManager.manager.searchAuthor(searchText)
                case .format:
                    vc.resultList = DataManager.manager.searchFormat(searchText)
                }
            } else {
                vc.resultList = []
            }
            vc.tableView.reloadData()
        }
    }

    @IBAction func onTapButton(_ sender: UIButton) {
        if let index = buttonGroup.arrangedSubviews.index(of: sender) {
            leadingLayout.constant = CGFloat(index) * sender.frame.size.width
            pageViewController.setViewControllers([resultVCS[index]], direction: .forward, animated: false, completion: nil)
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }) 
        searchWithText()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? UIPageViewController {
            pageViewController = vc
            pageViewController.delegate = self
            pageViewController.dataSource = self
            pageViewController.setViewControllers([resultVCS.first!], direction: .forward, animated: false, completion: nil)
        }
    }
}

extension SearchResultViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = resultVCS.index(of: viewController as! SearchResultListViewController) {
            if index > 1 {
                return nil
            }
            return resultVCS[index + 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = resultVCS.index(of: viewController as! SearchResultListViewController) {
            if index < 1 {
                return nil
            }
            return resultVCS[index - 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let index = resultVCS.index(of: pageViewController.viewControllers?.first! as! SearchResultListViewController) {
           leadingLayout.constant = CGFloat(index) * self.view.frame.size.width / 3
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            }) 
            self.searchWithText()
        }
    }
}
