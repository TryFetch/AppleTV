//
//  FullyReplaceSegue.swift
//  Fetch
//
//  Created by Stephen Radford on 30/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit

class FullyReplaceSegue: UIStoryboardSegue {

    override func perform() {
        
        if let presenting = sourceViewController.presentingViewController {
            presenting.dismissViewControllerAnimated(true) {
                UIApplication.sharedApplication().keyWindow?.rootViewController = self.destinationViewController
            }
        } else {
            UIApplication.sharedApplication().keyWindow?.rootViewController = self.destinationViewController
        }
        
        
    }
    
}
