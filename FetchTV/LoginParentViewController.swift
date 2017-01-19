//
//  LoginParentViewController.swift
//  Fetch
//
//  Created by Stephen Radford on 09/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit

class LoginParentViewController: UIViewController, LoginListenerDelegate {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        LoginListener.sharedInstance.delegate = self
    }
    
    func tokenGenerated() {
    }
    
    func loggedInOkay() {
        performSegueWithIdentifier("showMain", sender: self)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showMain" {
//            let vc = segue.destinationViewController
//            UIApplication.sharedApplication().keyWindow?.rootViewController = vc
//        }
//    }
    
}
