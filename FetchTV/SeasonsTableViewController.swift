//
//  SeasonsTableViewController.swift
//  Fetch
//
//  Created by Stephen Radford on 16/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit
import AVFoundation
import MediaPlayer

class SeasonsTableViewController: UITableViewController, SeasonsTableViewCellDelegate {

    var seasons: [String:[TVEpisode]] = [:]
    
    var episode: TVEpisode?
    
    var seasonTitles: [String] {
        get {
            return [String](seasons.keys)
        }
    }
    
    var orderedSeasons: [String] {
        get {
            return seasonTitles.sort({ $0 > $1 })
        }
    }
    
    /**
     Reload the seasons
     
     - parameter seasons: Season and TV Episodes
     */
    func reloadSeasons(seasons: [String:[TVEpisode]]!) {
        self.seasons = seasons
        if seasons.count == 1 {
            tableView?.scrollEnabled = false
            tableView?.maskView = nil
        }
        
        tableView?.reloadData()
    }
    
    
    
    // MARK: - UITableViewDatasource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return seasons.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return orderedSeasons[section].uppercaseString
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("episodesCollectionCell") as! SeasonsTableViewCell
        
        let key = orderedSeasons[indexPath.section]
        let season = seasons[key]!
        cell.episodes = season.sort({ $0.episodeNo! < $1.episodeNo! })
        cell.delegate = self
        cell.collectionView.reloadData()
        
        return cell
        
    }
    
    func performSegueWithEpisode(episode: TVEpisode) {
        self.episode = episode
        episode.file?.getTime {
            self.performSegueWithIdentifier("showPlayer", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let videoController: MediaPlayerViewController = segue.destinationViewController as! MediaPlayerViewController
        videoController.file = episode!.file
        let urlString = "\(Putio.api)files/\(episode!.file!.id)/hls/media.m3u8?oauth_token=\(Putio.accessToken!)&subtitle_key=default"
        let url = NSURL(string: urlString)
        
        let video = AVPlayerItem(URL: url!)
        
        if let image = episode!.still {
            let artwork = AVMutableMetadataItem()
            artwork.key = AVMetadataCommonKeyArtwork
            artwork.keySpace = AVMetadataKeySpaceCommon
            artwork.value = UIImagePNGRepresentation(image)
            artwork.locale = NSLocale.currentLocale()
            video.externalMetadata.append(artwork)
        }
        
        if let epTitle = episode!.title {
            let title = AVMutableMetadataItem()
            title.key = AVMetadataCommonKeyTitle
            title.keySpace = AVMetadataKeySpaceCommon
            title.value = epTitle
            title.locale = NSLocale.currentLocale()
            video.externalMetadata.append(title)
        }
        
        if let overview = episode!.overview {
            let description = AVMutableMetadataItem()
            description.key = AVMetadataCommonKeyDescription
            description.keySpace = AVMetadataKeySpaceCommon
            description.value = overview
            description.locale = NSLocale.currentLocale()
            video.externalMetadata.append(description)
        }
        
        videoController.player = AVPlayer(playerItem: video)
        
    }

    
}
