//
//  FetchNavigationController.swift
//  Fetch
//
//  Created by Stephen Radford on 16/09/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit

class FetchNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 48)!,
            NSForegroundColorAttributeName: UIColor(red:0.55, green:0.55, blue:0.57, alpha:1)
        ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
