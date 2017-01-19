//
//  SeasonsTableViewCell.swift
//  Fetch
//
//  Created by Stephen Radford on 16/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit
import AVKit

class SeasonsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var episodes: [TVEpisode] = []
    
    var file: File?
    
    var delegate: SeasonsTableViewCellDelegate?
    
    override func canBecomeFocused() -> Bool {
        return false
    }
    
    var focusPath = NSIndexPath(forRow: 0, inSection: 0)
    
    // MARK: UICollectionViewDataSource
    
    func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath? {
        return focusPath
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("episodeCell", forIndexPath: indexPath) as! EpisodeCollectionViewCell
        
        let ep = episodes[indexPath.row]
        
        cell.label.text = "\(ep.episodeNo!). \(ep.title!)"
        
        if let image = ep.still {
            cell.image.image = (ep.file!.accessed) ? compositeImage(image) : image
        } else {
            cell.image.image = (ep.file!.accessed) ? compositeImage(UIImage(named: "episode")!) : UIImage(named: "episode")
            ep.loadStill { image in
                UIView.transitionWithView(cell.image, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                    cell.image.image = (ep.file!.accessed) ? self.self.compositeImage(image) : image
                }, completion: nil)
            }
        }
        
        return cell
    }
    
    
    func compositeImage(image1: UIImage) -> UIImage {
        
        let size = CGSizeMake(308, 172);
        let scale: CGFloat = 0.0
        
        // Scale the image
        image1.drawAtPoint(CGPointMake(0, 0))
        UIGraphicsBeginImageContextWithOptions(size, false , scale)
        image1.drawInRect(CGRect(origin: CGPointZero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Draw the tick
        UIGraphicsBeginImageContextWithOptions(size, false , scale)
        scaledImage!.drawAtPoint(CGPointMake(0, 0))
        let tick = UIImage(named: "done")
        tick?.drawAtPoint(CGPointMake(0, 0))
        let result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return result!
        
    }
    
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let episode = episodes.sort({ $0.episodeNo! < $1.episodeNo! })[indexPath.row]
        episode.file?.accessed = true
        
        // TODO: See if we can fix the nasty animation change
        self.focusPath = indexPath
        self.collectionView.reloadItemsAtIndexPaths([indexPath])
        self.collectionView.updateFocusIfNeeded()
        
        delegate?.performSegueWithEpisode(episode)
    }
    

}
