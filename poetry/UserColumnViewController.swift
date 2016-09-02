//
//  UserColumnViewController.swift
//  poetry
//
//  Created by sunsing on 9/2/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit

class UserColumnViewController: UICollectionViewController {
    
    let refreshControl = UIRefreshControl()

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.addSubview(refreshControl)
        self.collectionView?.sendSubviewToBack(refreshControl)
        refreshControl.addTarget(self, action: #selector(UserColumnViewController.refresh), forControlEvents: .ValueChanged)
    }
    
    func refresh() {
        refreshControl.endRefreshing()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = self.view.frame.width
        let count = Int(width/96)
        let margin = (width - CGFloat(count * 96))/CGFloat(count + 1)
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: margin, bottom: 20, right: margin)
        if collectionView?.contentSize.height < collectionView?.frame.height {
            collectionView?.contentSize = CGSize(width: collectionView!.frame.width, height: collectionView!.frame.height + 1)
        }
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        return cell
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
