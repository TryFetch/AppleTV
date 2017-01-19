//
//  PosterCollectionViewCell.swift
//  Fetch
//
//  Created by Stephen Radford on 12/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit

class PosterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var poster: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        label.alpha = 0
        label.hidden = false
        label.layer.zPosition = 10
        label.layer.shadowColor = UIColor.blackColor().CGColor
        label.layer.shadowOffset = CGSizeMake(0, 1)
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.6
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
        coordinator.addCoordinatedAnimations({
            self.label.alpha = (self.focused) ? 1 : 0
        }, completion: nil)
        
    }


    
}
