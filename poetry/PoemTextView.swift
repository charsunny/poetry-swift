//
//  PoemTextView.swift
//  poetry
//
//  Created by 诺崇 on 16/5/12.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit
import TextAttributes

class PoemObject : NSObject {
    
    lazy var poemView : PoemTextView = {
        
        if let textView = NSBundle.mainBundle().loadNibNamed("PoemTextView", owner: self, options: nil).first as? PoemTextView {
            return textView
        }
        return PoemTextView()
    } ()
    
    @IBOutlet var poemTextView: PoemTextView!
    
}


@objc protocol PoemTextViewDelegate {
    optional func didClickToolbar(view:PoemTextView, button:UIButton, index:Int)
    optional func clickTextView(view:PoemTextView)
}

class PoemTextView: UIView {

    @IBOutlet var bgView: UIView!
    
    @IBOutlet var textView: UITextView!
    
    @IBOutlet var stackView: UIStackView!
    
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    weak var delegate:PoemTextViewDelegate?
    
    override func awakeFromNib() {
        textView.editable = false
        textView.alpha = 0
        indicatorView.startAnimating()
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.layoutManager.allowsNonContiguousLayout = true
        self.addParallaxEffect(textView, depth: 10)
        let fonts = ["\u{e620}", "\u{e62a}", "\u{e734}","\u{e614}","\u{e611}"]
        for view in stackView.arrangedSubviews where view is UIButton {
            let v = view as! UIButton
            let i = stackView.arrangedSubviews.indexOf(v)!
            v.setTitle(fonts[i], forState: .Normal)
            v.titleLabel?.font = UIFont(name: "iconfont", size: 24)
            v.setImage(nil, forState: .Normal)
        }
        self.textView.contentOffset = CGPointZero
        self.textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PoemTextView.clickTextView)))
    }
    
    func clickTextView() {
        self.delegate?.clickTextView?(self)
    }
    
    var poem:Poem? {
        didSet {
            if poem == nil {
                return
            }
            setPoemContent()
        }
    }
    
    private func setPoemContent() {
        
        let textStr = NSMutableAttributedString()
        
        let titleAttributes = TextAttributes()
        titleAttributes.font(name: UserFont, size: 26).lineSpacing(20).alignment(.Center).foregroundColor(UIColor.whiteColor())
        textStr.appendAttributedString(NSAttributedString(string: poem?.name ?? "", attributes: titleAttributes))
        textStr.appendAttributedString(NSAttributedString(string: "\n"))
        
        let authorAttributes = TextAttributes()
        authorAttributes.font(name: UserFont, size: 14).lineSpacing(8).alignment(.Right).foregroundColor(UIColor.whiteColor())
        textStr.appendAttributedString(NSAttributedString(string: poem?.author?.name ?? "", attributes: authorAttributes))
        textStr.appendAttributedString(NSAttributedString(string: "\n"))
        
        let textAttributes = TextAttributes()
        textAttributes.font(name: UserFont, size: 20).lineHeightMultiple(1.4).alignment(.Center).baselineOffset(8).foregroundColor(UIColor.whiteColor()).headIndent(8)
        textStr.appendAttributedString(NSAttributedString(string: poem?.content ?? "", attributes: textAttributes))
        self.textView.attributedText = textStr
        self.textView.contentOffset = CGPointZero
        self.textView.scrollEnabled = false
        self.textView.alpha = 1
        self.indicatorView.hidden = true
        if poem?.author == nil {
            if let button =  stackView.arrangedSubviews.last as? UIButton {
                button.enabled = false
            }
        }
        self.textView.contentOffset = CGPointZero
        self.textView.scrollRangeToVisible(NSMakeRange(0, 1))
//        dispatch_async(dispatch_get_main_queue()) { 
//            self.textView.scrollEnabled = true
//        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.textView.contentOffset = CGPointZero
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

    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
