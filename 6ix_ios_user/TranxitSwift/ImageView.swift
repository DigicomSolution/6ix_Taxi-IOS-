//
//  ImageView.swift
//  User
//
//  Created by CSS on 09/01/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
@IBDesignable
class ImageView: UIImageView {

    //MARK:- Make Rounded Corner
    @IBInspectable
    var isRoundedCorner : Bool = false {
        
        didSet {
            
            if isRoundedCorner {
                self.layer.masksToBounds = true
                self.layer.cornerRadius =  frame.height/2
            }
        }
        
    }
    
    
    @IBInspectable
    var imageTintColor : UIColor = .white {
        
        didSet {

            if isImageTintColor {

                self.image = self.image?.withRenderingMode(.alwaysTemplate)

                self.tintColor = imageTintColor

            }
        }
        
    }
    
    

    //MARK:- Make Image Tint Color
    @IBInspectable
    var isImageTintColor : Bool = false {
        
        didSet {
            
            if isImageTintColor {
              
                self.image = self.image?.withRenderingMode(.alwaysTemplate)
    
                self.tintColor = self.imageTintColor//UIColor.white

            }
        }
        
    }
    
    
    //MARK:- Make Image Tint Color
   // @IBInspectable
//    override var tintColor: UIColor? {
//
//        didSet {
//
//            if isImageTintColor {
//
//                self.image = self.image?.withRenderingMode(.alwaysTemplate)
//
//                if let color = tintColor{
//                    self.tintColor = color
//                }
//
//                //UIColor.white
//
//            }
//        }
//
//    }
    
    
    
    
    
}

extension UIImage {
    
    func imageWithInsets(insetDimen: CGFloat) -> UIImage {
        return imageWithInset(insets: UIEdgeInsets(top: insetDimen, left: insetDimen, bottom: insetDimen, right: insetDimen))
    }
    
    func imageWithInset(insets: UIEdgeInsets) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(self.renderingMode)
        UIGraphicsEndImageContext()
        return imageWithInsets!
    }
    
}
