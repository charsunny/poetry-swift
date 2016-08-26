//
//  PoemDetailViewController.swift
//  poetry
//
//  Created by 诺崇 on 16/5/13.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import TextAttributes
import Kingfisher

class PoemDetailViewController: UIViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate {
    
    var poem:Poem?

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
        if poem != nil {
            setPoemContent()
        }
        let fonts = ["\u{e620}", "\u{e62a}", "\u{e734}","\u{e614}","\u{e611}"]
        for view in stackView.arrangedSubviews where view is UIButton {
            let v = view as! UIButton
            let i = stackView.arrangedSubviews.indexOf(v)!
            v.setTitle(fonts[i], forState: .Normal)
            v.titleLabel?.font = UIFont(name: "iconfont", size: 24)
            v.setImage(nil, forState: .Normal)
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
        
        if let index = poem?.content?.hash {
            bgImageView.image = UIImage(named: "\(abs(index % 13 + 1)).jpg")
        }
        self.titleLabel.text = poem?.name
        self.authorLabel.text = poem?.author?.name ?? ""
        
        let textStr = NSMutableAttributedString()
        
        let titleAttributes = TextAttributes()
        titleAttributes.font(name: UserFont, size: 28).lineSpacing(20).alignment(.Center).foregroundColor(UIColor.whiteColor())
        textStr.appendAttributedString(NSAttributedString(string: poem?.name ?? "", attributes: titleAttributes))
        textStr.appendAttributedString(NSAttributedString(string: "\n"))
        
        let authorAttributes = TextAttributes()
        authorAttributes.font(name: UserFont, size: 18).lineSpacing(8).alignment(.Right).foregroundColor(UIColor.whiteColor())
        textStr.appendAttributedString(NSAttributedString(string: poem?.author?.name ?? "", attributes: authorAttributes))
        textStr.appendAttributedString(NSAttributedString(string: "\n"))
        
        let textAttributes = TextAttributes()
        textAttributes.font(name: UserFont, size: 24).lineHeightMultiple(1.4).alignment(.Center).baselineOffset(8).foregroundColor(UIColor.whiteColor()).headIndent(8)
        textStr.appendAttributedString(NSAttributedString(string: poem?.content ?? "", attributes: textAttributes))
        
        self.textView.attributedText = textStr
        self.textView.contentOffset = CGPointZero
        
        if poem?.author == nil {
            if let button =  stackView.arrangedSubviews.last as? UIButton {
                button.enabled = false
            }
        }
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
            vc.poet = self.poem!.author!
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
}
