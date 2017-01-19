//
//  MoviesCollectionViewController.swift
//  Fetch
//
//  Created by Stephen Radford on 13/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit
import Alamofire

class MoviesCollectionViewController: UICollectionViewController {

    var selectedMovie: Movie?
    
    var noMediaView: NoMediaView?
    
    var focusPath = NSIndexPath(forItem: 0, inSection: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noMediaView = NSBundle.mainBundle().loadNibNamed("NoMediaView", owner: self, options: nil)![0] as? NoMediaView
        noMediaView?.label.text = "No Movies Available"
        noMediaView?.frame = view.bounds
        noMediaView?.hidden = true
        view.addSubview(noMediaView!)
        
        showNoMediaMessageIfRequired()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MoviesCollectionViewController.tmdbLoaded(_:)), name: "TMDBFinished", object: Videos.sharedInstance)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MoviesCollectionViewController.refreshHasBegan), name: "RefreshBegan", object: nil)
        
        collectionView?.remembersLastFocusedIndexPath = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        showNoMediaMessageIfRequired()
        if !collectionView!.focused {
            focusPath = NSIndexPath(forItem: 0, inSection: 0)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
        if let next = context.nextFocusedIndexPath {
            focusPath = next
        }
        
    }
    
    override func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath? {
        return focusPath
    }
    
    // MARK: - Sync
    
    func tmdbLoaded(sender: AnyObject?) {
        showNoMediaMessageIfRequired()
        collectionView?.reloadData()
    }
    
    func refreshHasBegan() {
        if UIScreen.mainScreen().focusedView as? UICollectionViewCell == nil {
            focusPath = NSIndexPath(forItem: 0, inSection: 0)
            setNeedsFocusUpdate()
            updateFocusIfNeeded()
        }
    }

    func showNoMediaMessageIfRequired() {
        if Videos.sharedInstance.sortedMovies.count == 0 {
            noMediaView?.hidden = false
        } else {
            noMediaView?.hidden = true
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Videos.sharedInstance.sortedMovies.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("posterCell", forIndexPath: indexPath) as! PosterCollectionViewCell
        
        let movie = Videos.sharedInstance.sortedMovies[indexPath.row]
        cell.label.text = movie.title
        
        if let image = movie.poster {
            cell.poster.image = image
        } else {
            cell.poster.image = UIImage(named: "poster")
            movie.loadPoster { image in 
                UIView.transitionWithView(cell.poster, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                    cell.poster.image = image
                }, completion: nil)
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "tvShowsHeader", forIndexPath: indexPath)
    }
    
    // MARK: - Navigation
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        focusPath = indexPath
        selectedMovie = Videos.sharedInstance.sortedMovies[indexPath.row]
        performSegueWithIdentifier("showInfo", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! MovieInfoViewController
        vc.movie = selectedMovie
    }

}
