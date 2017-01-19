//
//  FetchTabBarController.swift
//  Fetch
//
//  Created by Stephen Radford on 15/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit

class FetchTabBarController: UITabBarController {

    var loadingView: ProgressView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FetchTabBarController.tmdbLoaded(_:)), name: "TMDBFinished", object: Videos.sharedInstance)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FetchTabBarController.putioFilesFetched(_:)), name: "PutioFinished", object: Videos.sharedInstance)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FetchTabBarController.progressUpdated(_:)), name: "TMDBUpdated", object: Videos.sharedInstance)
        
        loadingView = NSBundle.mainBundle().loadNibNamed("ProgressView", owner: self, options: nil)![0] as? ProgressView
        loadingView?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        loadingView?.progressBar.setProgress(0, animated: true)
        
        if Videos.sharedInstance.sortedMovies.count > 0 || Videos.sharedInstance.sortedTV.count > 0 || Videos.sharedInstance.files.count > 0 {
            loadingView?.hidden = true
            tmdbLoaded(self)
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "TriggerRefresh", object: nil))
        } else {
            Videos.sharedInstance.fetch()
        }
        
        view.addSubview(loadingView!)
        
    }
    
    func tmdbLoaded(sender: AnyObject?) {
        UIView.animateKeyframesWithDuration(1.0, delay: 0.5, options: [], animations: {
            self.loadingView?.alpha = 0
        }, completion: { complete in
            self.loadingView?.hidden = true
        })
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FetchTabBarController.refresh(_:)), name: "TriggerRefresh", object: nil)
    }
    
    func putioFilesFetched(sender: AnyObject?) {
        loadingView?.progressBar.setProgress(0.3, animated: true)
        loadingView?.Label.text = "Fetching TV & Movie Info…"
    }
    
    func progressUpdated(sender: AnyObject?) {
        let progress = (Videos.sharedInstance.completedPercent) * 0.7
        loadingView?.progressBar.setProgress(progress+0.3, animated: true)
    }
    
    // MARK: - Refresh
    
    func refresh(sender: AnyObject?) {
        print("Starting refresh...")
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "RefreshBegan", object: nil))
        Videos.sharedInstance.fetch()
    }
    
    
}
