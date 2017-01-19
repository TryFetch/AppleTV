//
//  URLViewController.swift
//  Fetch
//
//  Created by Stephen Radford on 15/09/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PutioKit

class URLViewController: LoginParentViewController {
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = LoginListener.sharedInstance.url
    }

}
