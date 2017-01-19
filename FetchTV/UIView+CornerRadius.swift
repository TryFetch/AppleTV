//
//  UIView+CornerRadius.swift
//  SellFormula
//
//  Created by Stephen Radford on 11/08/2015.
//

import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
}