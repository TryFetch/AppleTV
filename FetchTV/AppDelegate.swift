//
//  AppDelegate.swift
//  FetchTV
//
//  Created by Stephen Radford on 11/09/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit
import AVKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        showFirstRunIfRequired()
        
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        showFirstRunIfRequired()
    }

    // MARK: - First Run
    
    func showFirstRunIfRequired() {
        
        if NSUserDefaults.standardUserDefaults().boolForKey("logout") {
            Putio.keychain["access_token"] = nil
            Videos.sharedInstance.wipe()
            LoginListener.sharedInstance.getTVToken()
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "logout")
        }
        
        if Putio.accessToken == nil {
            let sb = UIStoryboard(name: "Login", bundle: nil)
            window?.rootViewController = sb.instantiateInitialViewController()
        } else if NSUserDefaults.standardUserDefaults().boolForKey("disableMediaSections") {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            window?.rootViewController = sb.instantiateViewControllerWithIdentifier("allFilesView")
        } else if ((window?.rootViewController as? FetchTabBarController) == nil) {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            window?.rootViewController = sb.instantiateInitialViewController()
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "TriggerRefresh", object: nil))
        }
    }
    
    // MARK: - Open With a URL
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        if url.host! == "play" {
            
            playVideoFromURL(url)
            
        } else if url.host! == "movie" {
            
            if let movies = NSUserDefaults(suiteName: "group.FetchPutIo")?.objectForKey("movies") as? [[String:AnyObject]] {
                
                let m = movies.filter({ $0["id"] as! String == url.pathComponents![1] })[0]
                let movie = Movie.fromCache(m)
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("movieInfo") as! MovieInfoViewController
                vc.movie = movie
                
                window?.rootViewController?.presentViewController(vc, animated: true, completion: nil)
            }
            
        } else if url.host! == "tv" {
            
            if let shows = NSUserDefaults(suiteName: "group.FetchPutIo")?.objectForKey("shows") as? [[String:AnyObject]] {
            
                let s = shows.filter({ $0["id"] as! String == url.pathComponents![1] })[0]
                let show = TVShow.fromCache(s)
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("showInfo") as! MediaInfoViewController
                vc.tvShow = show
                
                window?.rootViewController?.presentViewController(vc, animated: true, completion: nil)
                
            }
            
        }
        
        return true
    }

    func playVideoFromURL(url: NSURL) {
        let id = url.pathComponents![1]
        
        File.getFileById(id) { file in
            
            let videoController: MediaPlayerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mediaPlayer") as! MediaPlayerViewController
            videoController.file = file
            let urlString = "\(Putio.api)files/\(id)/hls/media.m3u8?oauth_token=\(Putio.accessToken!)&subtitle_key=default"
            let video = AVPlayerItem(URL: NSURL(string: urlString)!)
            
            var title: String?
            var overview: String?
            
            if let movies = NSUserDefaults(suiteName: "group.FetchPutIo")?.objectForKey("movies") as? [[String:String]] {
                let vid = movies.filter({ $0["fileID"] == id })[0]
                title = vid["title"]
                overview = vid["overview"]
            }
         
            if let t = title {
                let title = AVMutableMetadataItem()
                title.key = AVMetadataCommonKeyTitle
                title.keySpace = AVMetadataKeySpaceCommon
                title.value = t
                title.locale = NSLocale.currentLocale()
                video.externalMetadata.append(title)
            }
            
            if let overview = overview {
                let description = AVMutableMetadataItem()
                description.key = AVMetadataCommonKeyDescription
                description.keySpace = AVMetadataKeySpaceCommon
                description.value = overview
                description.locale = NSLocale.currentLocale()
                video.externalMetadata.append(description)
            }
            
            videoController.player = AVPlayer(playerItem: video)
            
            self.window?.rootViewController?.presentViewController(videoController, animated: true, completion: nil)
            
        }

    }
    
}

