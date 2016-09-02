//
//  PoemCardCell.swift
//  poetry
//
//  Created by sunsing on 8/26/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import TextAttributes

extension UILabel {
    func adjustFontSizeToFit() {
        var font = self.font;
        let size = self.frame.size;
        var maxSize = self.font.pointSize
        
        for ; maxSize >= self.minimumScaleFactor * self.font.pointSize; maxSize = maxSize - 1 {
            font = font.fontWithSize(maxSize)
            let constraintSize = CGSizeMake(size.width, CGFloat.max);
            
            if let textRect = self.text?.boundingRectWithSize(constraintSize, options:.UsesLineFragmentOrigin, attributes:[NSFontAttributeName:font], context:nil) {
                let  labelSize = textRect.size;
                if(labelSize.height <= size.height || maxSize < 13) {
                    self.font = font
                    self.setNeedsLayout()
                    break
                }
            }
            
        }
        // set the font to the minimum size anyway
        self.font = font;
        self.setNeedsLayout()
    }
}

let FlatDarkColors : [UIColor] = [UIColor.flatBlackColorDark(), UIColor.flatBlueColorDark(), UIColor.flatBrownColorDark(), UIColor.flatCoffeeColorDark(), UIColor.flatForestGreenColorDark(), UIColor.flatGrayColorDark(), UIColor.flatGreenColorDark(), UIColor.flatLimeColorDark(), UIColor.flatMagentaColorDark(), UIColor.flatMaroonColorDark(), UIColor.flatMintColorDark(), UIColor.flatNavyBlueColorDark(), UIColor.flatOrangeColorDark(), UIColor.flatPinkColorDark(), UIColor.flatPlumColorDark(), UIColor.flatPowderBlueColorDark(), UIColor.flatPurpleColorDark(), UIColor.flatRedColorDark(), UIColor.flatSandColorDark(), UIColor.flatSkyBlueColorDark(), UIColor.flatTealColorDark(), UIColor.flatWatermelonColorDark(), UIColor.flatWhiteColorDark(), UIColor.flatYellowColorDark()]

extension UIImage {

    static func imageWithString(string: String, size: CGSize) -> UIImage {
        
        let label = UILabel(frame: CGRect(x: 0, y:  0, width: 2*size.width/3, height: 2*size.height/3))
        label.numberOfLines = 0
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.userFontWithSize(size.width/2)
        label.text = string
        label.textAlignment = .Center
        label.adjustFontSizeToFit()
        UIColor.flatBlackColor()
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        FlatDarkColors[string.hash % FlatDarkColors.count].set()
        UIRectFill(CGRect(origin: CGPointZero, size: size))
        label.drawTextInRect(CGRect(x: size.width/6, y:  size.height/6, width: 2*size.width/3, height: 2*size.height/3))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image.af_imageRoundedIntoCircle()
    }
}