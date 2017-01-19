//
//  PosterHeaderCollectionReusableView.swift
//  Fetch
//
//  Created by Stephen Radford on 04/11/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit

class PosterHeaderCollectionReusableView: UICollectionReusableView {
    
    private var focusGuide = UIFocusGuide()
    
    @IBOutlet weak var syncBtn: UIButton!
    
    @IBAction func refresh(sender: AnyObject) {
        print("trigger from button")
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "TriggerRefresh", object: nil))
    }
    
    override func awakeFromNib() {
        syncBtn.setTitle("Syncing...", forState: UIControlState.Disabled)
        if Videos.sharedInstance.syncing {
            syncBtn.enabled = false
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PosterHeaderCollectionReusableView.refreshHasBegan), name: "RefreshBegan", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PosterHeaderCollectionReusableView.finishedRefresh), name: "RefreshComplete", object: Videos.sharedInstance)
    }
    
    override func prepareForReuse() {
        addLayoutGuide(focusGuide)
        focusGuide.preferredFocusedView = syncBtn
        
        // Anchor the top left of the focus guide.
        focusGuide.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        focusGuide.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        focusGuide.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        focusGuide.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
    }
    
    
    func finishedRefresh() {
        syncBtn.enabled = true
    }
    
    func refreshHasBegan() {
        syncBtn.enabled = false
    }
    
}
