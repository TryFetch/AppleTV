//
//  UIImage+AverageColor.swift
//  Fetch
//
//  Created by Stephen Radford on 17/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit

extension UIImage {
    
    func averageColor() -> UIColor {
        
        let rgba = UnsafeMutablePointer<CUnsignedChar>.alloc(4)
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()
        let info = CGImageAlphaInfo.PremultipliedLast.rawValue
        let context: CGContextRef = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, info)!

        CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage!)
        
        if rgba[3] > 0 {
            
            let alpha: CGFloat = CGFloat(rgba[3]) / 255.0
            let multiplier: CGFloat = alpha / 255.0
            
            return UIColor(red: CGFloat(rgba[0]) * multiplier, green: CGFloat(rgba[1]) * multiplier, blue: CGFloat(rgba[2]) * multiplier, alpha: alpha)
            
        } else {
            
            return UIColor(red: CGFloat(rgba[0]) / 255.0, green: CGFloat(rgba[1]) / 255.0, blue: CGFloat(rgba[2]) / 255.0, alpha: CGFloat(rgba[3]) / 255.0)
        }
    }
    
    func isDark() -> Bool {
        let components = CGColorGetComponents(self.averageColor().CGColor)
        
        let section1 = (components[0] * 299)
        let section2 = (components[1] * 587)
        let section3 = (components[2] * 114)
        
        let brightness = (section1 + section2 + section3) / 1000
        
        if brightness > 0.7 {
            return false
        }

        return true
    }
    
}
