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
        if let poem = self.poem , poemId == 0 {
            poemId = poem.id
        }
        self.titleLabel.font = UIFont.userFont(size:18)
        self.authorLabel.font = UIFont.userFont(size:13)
        textView.isEditable = false
        textView.delegate = self
        textView.alpha = 0
        indicator.startAnimating()
        self.titleView.alpha = 0
        self.titleView.isHidden = true
        self.titleView.frame = CGRect(x: 30, y: 7, width: UIScreen.main.bounds.width - 88, height: 30)
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 8, bottom: 12, right: 8)
        textView.isUserInteractionEnabled = true
        self.addParallaxEffect(textView, depth: 10)
        textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PoemDetailViewController.onTapText(_:))))
        if LocalDBExist {
            DispatchQueue.main.async(execute: { 
                self.poem = DataManager.manager.poemById(self.poemId)
                self.poem?.loadPoet()
                DispatchQueue.main.async(execute: { 
                    self.setPoemContent()
                })
            })
            Poem.GetPoemDetail(poemId, finish: { (p, err) in
                self.updateToolbar(p?.commentCount ?? 0, ft: p?.likeCount ?? 0, isFav: p?.isFav ?? false)
            })
        } else {
            Poem.GetPoemDetail(poemId, finish: { (p, err) in
                if err != nil {
                    //HUD.flash(.labeledError(title: "加载失败", subtitle: nil), delay: 1.0)
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
    func onTapText(_ gesture:UITapGestureRecognizer) {
        let textView = gesture.view as! UITextView
        var point = gesture.location(in: textView)
        point.x -= textView.textContainerInset.left
        point.y -= textView.textContainerInset.top
        let index = textView.layoutManager.glyphIndex(for: point, in: textView.textContainer, fractionOfDistanceThroughGlyph: nil)
        if index < textView.textStorage.length {
            self.tapIndex = index
            keyword = (textView.attributedText.string as NSString).substring(with: NSRange(location: index, length: 1))
            if keyword.isHanZi() {
                let pt = textView.layoutManager.boundingRect(forGlyphRange: NSRange(location: index, length: 1), in: textView.textContainer)
                self.performSegue(withIdentifier: "popover", sender: NSValue(cgRect: pt))
            }
        }
    }
    
    fileprivate func setPoemContent() {
        
        if let index = poem?.content.hash {
            bgImageView.image = UIImage(named: "\(abs(index % 13 + 1)).jpg")
        }
        self.titleLabel.text = poem?.title
        self.authorLabel.text = poem?.poet?.name ?? ""
        
        let textStr = NSMutableAttributedString()
        
        let titleAttributes = TextAttributes()
        titleAttributes.font(UIFont.userFont(size:28)).lineSpacing(20).alignment(.center).foregroundColor(UIColor.white)
        textStr.append(NSAttributedString(string: poem?.title ?? "", attributes: titleAttributes))
        textStr.append(NSAttributedString(string: "\n"))
        
        let authorAttributes = TextAttributes()
        authorAttributes.font(UIFont.userFont(size:16)).lineSpacing(8).alignment(.right).foregroundColor(UIColor.white)
        textStr.append(NSAttributedString(string: poem?.poet?.name ?? "", attributes: authorAttributes))
        textStr.append(NSAttributedString(string: "\n"))
        
        let textAttributes = TextAttributes()
        textAttributes.font(UIFont.userFont(size:24)).lineHeightMultiple(1.4).alignment(.center).baselineOffset(8).foregroundColor(UIColor.white).headIndent(8)
        textStr.append(NSAttributedString(string: poem?.content ?? "", attributes: textAttributes))
        
        self.textView.attributedText = textStr
        self.textView.contentOffset = CGPoint.zero
        
        if poem?.poet == nil {
            if let button =  stackView.arrangedSubviews.last as? UIButton {
                button.isEnabled = false
            }
        }
    }
    
    @IBAction func onLike(_ sender: UIButton) {
        if User.LoginUser == nil {
            //HUD.flash(.label("尚未登录"), delay: 1.0)
            return
        }
        guard let poem = self.poem else {return }
        poem.like({ (result, err) in
            if err != nil {
                //HUD.flash(.labeledError(title: nil, subtitle:  String.ErrorString(err!)), delay: 1.0)
            } else {
                //HUD.flash(.labeledSuccess(title: nil, subtitle: result), delay: 1.0)
            }
            sender.setImage(UIImage(named: poem.isFav ? "heart" : "hert") , for: UIControlState())
            sender.setTitle("\(poem.likeCount)", for: UIControlState())
            sender.tintColor = poem.isFav ? UIColor.flatRed() : UIColor.white
        })
    }
    
    func updateToolbar(_ ct:Int, ft:Int, isFav: Bool) {
        let commentButton = stackView.arrangedSubviews[0] as! UIButton
        let likeButton = stackView.arrangedSubviews[1] as! UIButton
        commentButton.setTitle("\(ct)", for: UIControlState())
        likeButton.setTitle("\(ft)", for: UIControlState())
        likeButton.setImage(UIImage(named: isFav ? "heart" : "hert") , for: UIControlState())
        likeButton.tintColor = isFav ? UIColor.flatRed() : UIColor.white
    }
    
    fileprivate func addParallaxEffect(_ view:UIView, depth:CGFloat) {
        let effectX = UIInterpolatingMotionEffect(keyPath:"center.x", type:.tiltAlongHorizontalAxis)
        let effectY = UIInterpolatingMotionEffect(keyPath:"center.y", type: .tiltAlongVerticalAxis)
        effectX.maximumRelativeValue = depth
        effectX.minimumRelativeValue = -depth
        effectY.maximumRelativeValue = depth
        effectY.minimumRelativeValue = -depth
        view.addMotionEffect(effectX)
        view.addMotionEffect(effectY)
    }

    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navController = navigationController
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.titleView.frame = CGRect(x: 30, y: 7, width: UIScreen.main.bounds.width - 88, height: 30)
        if self.navigationController?.navigationBar.backgroundImage(for: .default) == nil {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
    
    var navController: UINavigationController?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.parent is UIPageViewController {
            return
        }
        self.navController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navController?.navigationBar.shadowImage = nil
    }
    
    var isLoadView = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isLoadView {
            self.textView.setContentOffset(CGPoint.zero, animated: false)
            isLoadView = false
        }
        UIView.animate(withDuration: 0.1, animations: {
            self.textView.alpha = 1.0
            self.indicator.isHidden = true
        }) 
        
    }
    
    // MARK: -- textview delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 90 {
            var parentTitleView:UIView? = nil
            if let vc = self.parent as? PoemWonderViewController {
                parentTitleView = vc.titleView
            }
            let alpha = scrollView.contentOffset.y/90.0
            if alpha < 0.3 {
                self.titleView.isHidden = true
                parentTitleView?.isHidden = true
            } else {
                self.titleView.isHidden = false
                parentTitleView?.isHidden = false
            }
            self.titleView.alpha = alpha
            parentTitleView?.alpha = alpha
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    var transitioner:CAVTransitioner?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? DictViewController {
            if let rect = (sender as? NSValue)?.cgRectValue {
                vc.popoverPresentationController?.backgroundColor = UIColor.white
                vc.popoverPresentationController?.sourceRect = CGRect(x: rect.midX, y: rect.midY, width: rect.width, height: rect.height)
                vc.popoverPresentationController?.sourceView = self.textView
                vc.popoverPresentationController?.delegate = self
                vc.keyword = keyword
            }
        }
        if let vc = segue.destination as? AuthorViewController {
            vc.poet = self.poem!.poet!
        }
        if let vc = segue.destination as? PoemCommentViewController {
            vc.poem = self.poem
        }
        if let vc = segue.destination as? UINavigationController {
            if let pvc = vc.viewControllers.first as? ExploreAddViewController {
                pvc.poem = self.poem
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
}
