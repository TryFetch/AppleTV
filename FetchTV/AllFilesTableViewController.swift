//
//  AllFilesTableViewController.swift
//  Fetch
//
//  Created by Stephen Radford on 19/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit

class AllFilesTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.remembersLastFocusedIndexPath = true
        tableView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 60, right: 0)
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
        let p = parent as! AllFilesViewController
        tableView.dataSource = p
        tableView.delegate = p
    }
    
}
