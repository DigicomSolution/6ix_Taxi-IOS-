//
//  Image.swift
//  User
//
//  Created by CSS on 09/01/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resizeImage(newWidth: CGFloat) -> UIImage?{
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(origin: .zero, size: CGSize(width: newWidth, height: newHeight)))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    //MARK:- Image Comparision 
    
    func isEqual(to image : UIImage?) -> Bool {
        
        guard  image != nil, let imageData1 = image!.pngData()  else {
            return false
        }
        
        guard let imageData2 = self.pngData() else {
            return false
        }
        
        return imageData1 == imageData2
        
    }
    
//    //MARK:- Get Image color from specific point
//    func getPixelColor(pos: CGPoint, alpha : CGFloat = 1) -> UIColor? {
//        
//        guard let pixelData =  self.cgImage?.dataProvider?.data, let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData) else {
//            return .clear
//        }
//        
//        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
//        
//        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
//        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
//        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
//        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
//        
//        return UIColor(red: r, green: g, blue: b, alpha: a*alpha)
//    }
//    
    
}
