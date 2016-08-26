//
//  UIGradientView.swift
//  poetry
//
//  Created by 诺崇 on 16/5/13.
//  Copyright © 2016年 诺崇. All rights reserved.
//

import UIKit

@IBDesignable
class UIGradientView: UIView {

    @IBInspectable var startColor:UIColor = UIColor.blackColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var endColor:UIColor = UIColor.whiteColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var startLocation:CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var endLocation:CGFloat = 1.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var gradientLayer:CAGradientLayer!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clearColor()
        gradientLayer = CAGradientLayer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        gradientLayer = CAGradientLayer()
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        self.gradientLayer.frame = rect
        self.gradientLayer.locations = [startLocation, endLocation]
        self.gradientLayer.colors = [startColor.CGColor, endColor.CGColor]
        if self.layer.sublayers == nil || self.layer.sublayers?.count == 0 {
            self.layer.insertSublayer(self.gradientLayer, atIndex: 0)
        }
        if self.layer.sublayers?.first != self.gradientLayer {
            self.layer.insertSublayer(self.gradientLayer, atIndex: 0)
        }
    }

}
