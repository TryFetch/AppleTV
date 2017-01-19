//
//  FocusableText.swift
//  Fetch
//
//  Created by Stephen Radford on 15/11/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit

class FocusableText: UIView {

    @IBOutlet weak var visualEffect: UIVisualEffectView!
    
    override func awakeFromNib() {
        visualEffect.cornerRadius = 10
        visualEffect.alpha = 0
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSizeMake(0, 3)
        layer.shadowRadius = 15
        layer.shadowOpacity = 0.4
    }
    
    override func canBecomeFocused() -> Bool {
        return true
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
        if context.nextFocusedView == self {
            visualEffect.alpha = 1
        } else {
            visualEffect.alpha = 0
        }
        
    }

}
