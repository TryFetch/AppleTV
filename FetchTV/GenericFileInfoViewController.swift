//
//  GenericFileInfoViewController.swift
//  Fetch
//
//  Created by Stephen Radford on 19/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit

class GenericFileInfoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var fileSizeLabel: UILabel!
    
    @IBOutlet weak var subtitlesLabel: UILabel!
    
    @IBOutlet weak var fileAccessedLabel: UILabel!
    
    @IBOutlet weak var contentTypeLabel: UILabel!
    
    @IBOutlet weak var imageContainer: UIView!
    
    override func viewDidLoad() {
        imageContainer.layer.shadowColor = UIColor.blackColor().CGColor
        imageContainer.layer.shadowOffset = CGSizeMake(0, 2)
        imageContainer.layer.shadowRadius = 5
        imageContainer.layer.shadowOpacity = 0.2
    }
    
}
