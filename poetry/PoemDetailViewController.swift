//
//  PoemDetailViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/13.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import TextAttributes
import AlamofireImage
import PKHUD

class PoemDetailViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate {
    
    var poem:Poem?
    
    var poemId:Int = 0

    @IBOutlet var indicator: UIActivityIndicatorView!
    
    @IBOutlet var bgImageView: UIImageView!
    
    @IBOutlet var titleView: UIView!
    
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var authorLabel: UILabel!
    
    @IBOutlet var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.font = UIFont(name: UserFont, size: 18)
        self.authorLabel.font = UIFont(name: UserFont, size: 13)
        textView.editable = false
        textView.delegate = self
        textView.alpha = 0
        indicator.startAnimating()
        self.titleView.alpha = 0
        self.titleView.hidden = true
        self.titleView.frame = CGRectMake(30, 7, UIScreen.mainScreen().bounds.width - 88, 30)
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 8, bottom: 12, right: 8)
        textView.userInteractionEnabled = true
        self.addParallaxEffect(textView, depth: 10)
        textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PoemDetailViewController.onTapText(_:))))
        if LocalDBExist {
            dispatch_async(dispatch_get_main_queue(), { 
                self.poem = DataManager.manager.poemById(self.poemId)
                self.poem?.loadPoet()
                dispatch_async(dispatch_get_main_queue(), { 
                    self.setPoemContent()
                })
            })
            Poem.GetPoemDetail(poemId, finish: { (p, err) in
                if err != nil {
                    HUD.flash(.LabeledError(title: "加载失败", subtitle: nil), delay: 1.0)
                } else {
                    self.setPoemContent()
                    self.updateToolbar(p?.commentCount ?? 0, ft: p?.likeCount ?? 0, isFav: p?.isFav ?? false)
                }
            })
        } else {
            Poem.GetPoemDetail(poemId, finish: { (p, err) in
                if err != nil {
                    HUD.flash(.LabeledError(title: "加载失败", subtitle: nil), delay: 1.0)
                } else {
                    self.poem = p
                    self.setPoemContent()
                    self.updateToolbar(p?.commentCount ?? 0, ft: p?.likeCount ?? 0, isFav: p?.isFav ?? false)
                }
            })
        }
    }
    
    var tapIndex:Int = -1
    var keyword:String = ""
    func onTapText(gesture:UITapGestureRecognizer) {
        let textView = gesture.view as! UITextView
        var point = gesture.locationInView(textView)
        point.x -= textView.textContainerInset.left
        point.y -= textView.textContainerInset.top
        let index = textView.layoutManager.glyphIndexForPoint(point, inTextContainer: textView.textContainer, fractionOfDistanceThroughGlyph: nil)
        if index < textView.textStorage.length {
            self.tapIndex = index
            keyword = (textView.attributedText.string as NSString).substringWithRange(NSRange(location: index, length: 1))
            if keyword.isHanZi() {
                let pt = textView.layoutManager.boundingRectForGlyphRange(NSRange(location: index, length: 1), inTextContainer: textView.textContainer)
                self.performSegueWithIdentifier("popover", sender: NSValue(CGRect: pt))
            }
        }
    }
    
    private func setPoemContent() {
        
        if let index = poem?.content.hash {
            bgImageView.image = UIImage(named: "\(abs(index % 13 + 1)).jpg")
        }
        self.titleLabel.text = poem?.title
        self.authorLabel.text = poem?.poet?.name ?? ""
        
        let textStr = NSMutableAttributedString()
        
        let titleAttributes = TextAttributes()
        titleAttributes.font(name: UserFont, size: 28).lineSpacing(20).alignment(.Center).foregroundColor(UIColor.whiteColor())
        textStr.appendAttributedString(NSAttributedString(string: poem?.title ?? "", attributes: titleAttributes))
        textStr.appendAttributedString(NSAttributedString(string: "\n"))
        
        let authorAttributes = TextAttributes()
        authorAttributes.font(name: UserFont, size: 18).lineSpacing(8).alignment(.Right).foregroundColor(UIColor.whiteColor())
        textStr.appendAttributedString(NSAttributedString(string: poem?.poet?.name ?? "", attributes: authorAttributes))
        textStr.appendAttributedString(NSAttributedString(string: "\n"))
        
        let textAttributes = TextAttributes()
        textAttributes.font(name: UserFont, size: 24).lineHeightMultiple(1.4).alignment(.Center).baselineOffset(8).foregroundColor(UIColor.whiteColor()).headIndent(8)
        textStr.appendAttributedString(NSAttributedString(string: poem?.content ?? "", attributes: textAttributes))
        
        self.textView.attributedText = textStr
        self.textView.contentOffset = CGPointZero
        
        if poem?.poet == nil {
            if let button =  stackView.arrangedSubviews.last as? UIButton {
                button.enabled = false
            }
        }
    }
    
    @IBAction func onLike(sender: UIButton) {
        guard let poem = self.poem else {return }
        poem.like({ (result, err) in
            if err != nil {
                HUD.flash(.LabeledError(title: nil, subtitle:  String.ErrorString(err!)), delay: 1.0)
            } else {
                HUD.flash(.LabeledSuccess(title: nil, subtitle: result), delay: 1.0)
            }
            sender.setImage(UIImage(named: poem.isFav ? "heart" : "hert") , forState: .Normal)
            sender.setTitle("\(poem.likeCount)", forState: .Normal)
            sender.tintColor = poem.isFav ? UIColor.flatRedColor() : UIColor.whiteColor()
        })
    }
    
    func updateToolbar(ct:Int, ft:Int, isFav: Bool) {
        let commentButton = stackView.arrangedSubviews[0] as! UIButton
        let likeButton = stackView.arrangedSubviews[1] as! UIButton
        commentButton.setTitle("\(ct)", forState: .Normal)
        likeButton.setTitle("\(ft)", forState: .Normal)
        likeButton.setImage(UIImage(named: isFav ? "heart" : "hert") , forState: .Normal)
        likeButton.tintColor = isFav ? UIColor.flatRedColor() : UIColor.whiteColor()
    }
    
    private func addParallaxEffect(view:UIView, depth:CGFloat) {
        let effectX = UIInterpolatingMotionEffect(keyPath:"center.x", type:.TiltAlongHorizontalAxis)
        let effectY = UIInterpolatingMotionEffect(keyPath:"center.y", type: .TiltAlongVerticalAxis)
        effectX.maximumRelativeValue = depth
        effectX.minimumRelativeValue = -depth
        effectY.maximumRelativeValue = depth
        effectY.minimumRelativeValue = -depth
        view.addMotionEffect(effectX)
        view.addMotionEffect(effectY)
    }

    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navController = navigationController
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.titleView.frame = CGRectMake(30, 7, UIScreen.mainScreen().bounds.width - 88, 30)
        if self.navigationController?.navigationBar.backgroundImageForBarMetrics(.Default) == nil {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
    
    var navController: UINavigationController?
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.navController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navController?.navigationBar.shadowImage = nil
    }
    
    var isLoadView = true
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if isLoadView {
            self.textView.setContentOffset(CGPointZero, animated: false)
            isLoadView = false
        }
        UIView.animateWithDuration(0.1) {
            self.textView.alpha = 1.0
            self.indicator.hidden = true
        }
        
    }
    
    // MARK: -- textview delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 90 {
            let alpha = scrollView.contentOffset.y/90.0
            if alpha < 0.3 {
                self.titleView.hidden = true
            } else {
                self.titleView.hidden = false
            }
            self.titleView.alpha = alpha
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    var transitioner:CAVTransitioner?
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destinationViewController as? DictViewController {
            if let rect = (sender as? NSValue)?.CGRectValue() {
                vc.popoverPresentationController?.backgroundColor = UIColor.whiteColor()
                vc.popoverPresentationController?.sourceRect = CGRectMake(rect.midX, rect.midY, rect.width, rect.height)
                vc.popoverPresentationController?.sourceView = self.textView
                vc.popoverPresentationController?.delegate = self
                vc.keyword = keyword
            }
        }
        if let vc = segue.destinationViewController as? AuthorViewController {
            vc.poet = self.poem!.poet!
        }
        if let vc = segue.destinationViewController as? PoemCommentViewController {
            vc.poem = self.poem
        }
        if let pvc = segue.destinationViewController as? ExploreAddViewController {
            transitioner = CAVTransitioner()
            if self.traitCollection.userInterfaceIdiom == .Pad {
                pvc.preferredContentSize = CGSize(width: 320, height: 200)
            } else {
                pvc.preferredContentSize = CGSize(width: UIScreen.mainScreen().bounds.width - 40, height: 200)
            }
            pvc.poemId = self.poemId
            pvc.modalPresentationStyle = UIModalPresentationStyle.Custom
            pvc.transitioningDelegate = transitioner
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
}
