//
//  PoemCardCell.swift
//  poetry
//
//  Created by sunsing on 8/26/16.
//  Copyright © 2016 诺崇. All rights reserved.
//

import UIKit
import TextAttributes
import SVProgressHUD

typealias HUD = SVProgressHUD

public enum SVProgressHUDStyle {
    case success(String)
    case error(String)
    case info(String)
    case `default`
}

extension SVProgressHUD {
    static public func flash(_ style : SVProgressHUDStyle, delay : TimeInterval) {
        SVProgressHUD.setMinimumDismissTimeInterval(delay)
        switch style {
        case .success(let text):
            SVProgressHUD.showSuccess(withStatus: text)
        case .error(let text):
            SVProgressHUD.showError(withStatus: text)
        case .info(let text):
            SVProgressHUD.showInfo(withStatus: text)
        case .default:
            SVProgressHUD.show()
            SVProgressHUD.dismiss(withDelay: delay)
        }
    }
}

extension UILabel {
    func adjustFontSizeToFit() {
        var font = self.font;
        let size = self.frame.size;
        var maxSize = self.font.pointSize
        
        while maxSize >= self.minimumScaleFactor * self.font.pointSize {
            
            font = font?.withSize(maxSize)
            let constraintSize = CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude);
            
            if let textRect = self.text?.boundingRect(with: constraintSize, options:.usesLineFragmentOrigin, attributes:[NSFontAttributeName:font!], context:nil) {
                let  labelSize = textRect.size;
                if(labelSize.height <= size.height || maxSize < 13) {
                    self.font = font
                    self.setNeedsLayout()
                    break
                }
            }
            maxSize = maxSize - 1
        }
        // set the font to the minimum size anyway
        self.font = font;
        self.setNeedsLayout()
    }
}

let FlatDarkColors : [UIColor] = [UIColor.flatBlackColorDark(), UIColor.flatBlueColorDark(), UIColor.flatBrownColorDark(), UIColor.flatCoffeeColorDark(), UIColor.flatForestGreenColorDark(), UIColor.flatGrayColorDark(), UIColor.flatGreenColorDark(), UIColor.flatLimeColorDark(), UIColor.flatMagentaColorDark(), UIColor.flatMaroonColorDark(), UIColor.flatMintColorDark(), UIColor.flatNavyBlueColorDark(), UIColor.flatOrangeColorDark(), UIColor.flatPinkColorDark(), UIColor.flatPlumColorDark(), UIColor.flatPowderBlueColorDark(), UIColor.flatPurpleColorDark(), UIColor.flatRedColorDark(), UIColor.flatSandColorDark(), UIColor.flatSkyBlueColorDark(), UIColor.flatTealColorDark(), UIColor.flatWatermelonColorDark(), UIColor.flatWhiteColorDark(), UIColor.flatYellowColorDark()]

extension UIImage {

    static func imageWithString(_ string: String, size: CGSize) -> UIImage {
        
        let label = UILabel(frame: CGRect(x: 0, y:  0, width: 2*size.width/3, height: 2*size.height/3))
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.font = UIFont.userFont(size:size.width/2)
        label.text = string
        label.textAlignment = .center
        label.adjustFontSizeToFit()
        UIColor.flatBlack()
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        FlatDarkColors[abs(string.hash) % FlatDarkColors.count].set()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        label.drawText(in: CGRect(x: size.width/6, y:  size.height/6, width: 2*size.width/3, height: 2*size.height/3))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!.af_imageRoundedIntoCircle()
    }
}
