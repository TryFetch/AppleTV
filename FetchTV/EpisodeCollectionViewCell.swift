//
//  EpisodeCollectionViewCell.swift
//  Fetch
//
//  Created by Stephen Radford on 16/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit

class EpisodeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var image: UIImageView!
    
    override func awakeFromNib() {
        label.layer.zPosition = 10
        label.layer.shadowColor = UIColor.blackColor().CGColor
        label.layer.shadowOffset = CGSizeMake(0, 1)
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.6
        label.hidden = false
        label.alpha = 0
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({
            self.label.alpha = (self.focused) ? 1 : 0
        }, completion: nil)
    }
    
}
