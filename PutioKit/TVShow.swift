//
//  Show.swift
//  Fetch
//
//  Created by Stephen Radford on 10/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import Downpour
import Alamofire

public class TVShow {
    
    /// The TV Show ID
    public var id: Int?
    
    /// Delegate for the TVShow
    public var delegate: TVShowDelegate?
    
    /// URL to the backdrop on the API
    public var backdropURL: String?
    
    /// The backdrop of the image
    public var backdrop: UIImage?
    
    /// URL to the poster on the API
    public var posterURL: String?
    
    /// The poster image
    public var poster: UIImage?
    
    /// The name of the TV Show
    public var title: String?
    
    /// Title to sort alphabetically witout "The"
    public var sortableTitle: String? {
        get {
            if let range = title?.rangeOfString("The ") {
                if range.startIndex == title?.startIndex {
                    return title?.stringByReplacingCharactersInRange(range, withString: "")
                }
            }
            return title
        }
    }
    
    /// Description of the TV Show
    public var overview: String?
    
    /// voting average of the tv show
    public var voteAverage: Float64?
    
    /// TV show genre
    public var genres: [Genre]?
    
    /// Putio Files
    public var files: [File] = []
    
    public var seasons: [String:[TVEpisode]] = [:]
    
    var requests = 0
    
    private var completed = 0
    
    public var completedPercent: Float {
        get {
            return (Float(self.completed) / Float(self.files.count))
        }
    }
    
    /**
     Convert the files to TV Episodes
     */
    public func convertFilesToEpisodes() {
        
        guard seasons.count == 0 else {
            self.delegate?.tvEpisodesLoaded()
            return
        }
        
        TMDB.sharedInstance.requests = 0
        
        for file in files {
            
            requests += 1
            
            let d = Downpour(string: file.name)
            if d.season != nil && d.episode != nil {
                
                TMDB.fetchEpisodeForSeason(d.season!, episode: d.episode!, showId: id!) { episode in
                    self.requests -= 1
                    self.completed += 1
                    self.delegate?.percentUpdated()
                    
                    if let ep = episode {
                        
                        if ep.seasonNo != nil {
                            ep.file = file
                            if self.seasons["Season \(ep.seasonNo!)"] != nil {
                                self.seasons["Season \(ep.seasonNo!)"]!.append(ep)
                            } else {
                                self.seasons["Season \(ep.seasonNo!)"] = [ep]
                            }
                        }
                        
                    }
                    
                    if self.requests == 0 {
                        TMDB.sharedInstance.requests = 0
                        self.delegate?.tvEpisodesLoaded()
                    }
    
                }
            }
            
            
            
        }
    }
    
    /// Load the movie poster
    public func loadPoster(callback: (UIImage) -> Void) {
        
        let documents = NSURL(string: NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0])
        let lcrPath = documents!.URLByAppendingPathComponent("\(id!).lcr")
        let pngPath = documents!.URLByAppendingPathComponent("\(id!).png")
        let fm = NSFileManager.defaultManager()
        var isDir: ObjCBool = false
        
        if fm.fileExistsAtPath(lcrPath!.absoluteString!, isDirectory: &isDir) {
            poster = UIImage(contentsOfFile: lcrPath!.absoluteString!)
            if self.poster != nil {
                callback(self.poster!)
            }
        } else if fm.fileExistsAtPath(pngPath!.absoluteString!, isDirectory: &isDir) {
            poster = UIImage(contentsOfFile: pngPath!.absoluteString!)
            if self.poster != nil {
                callback(self.poster!)
            }
        } else {
            
            let params = ["title": title!]
            
            Alamofire.request(.GET, "http://lsrdb.com/search", parameters: params)
                .responseData { response in
                    
                    if response.result.isSuccess && response.response!.statusCode == 200 {
                        
                        if let image = response.result.value {
                            image.writeToFile(lcrPath!.absoluteString!, atomically: true)
                            self.poster = UIImage(contentsOfFile: lcrPath!.absoluteString!)
                            if self.poster != nil {
                                callback(self.poster!)
                            }
                        }
                        
                    } else if let url = self.posterURL {
                        
                        Alamofire.request(.GET, "https://image.tmdb.org/t/p/w500\(url)")
                            .responseImage { response in
                                if let image = response.result.value {
                                    UIImagePNGRepresentation(image)?.writeToFile(pngPath!.absoluteString!, atomically: true)
                                    self.poster = image
                                    if self.poster != nil {
                                        callback(self.poster!)
                                    }
                                }
                        }
                        
                    }
                    
            }
            
        }

        
    }
    
    
    public class func fromCache(cache: [String:AnyObject]) -> TVShow {
        
        let files: [File] = (cache["files"] as! [[String:AnyObject]]).map { file in
            
            let id = Int32(file["id"] as! Int)
            let name = file["name"] as! String
            let screenshot = file["screenshot"] as! String
            let start_from = file["start_from"] as! Double
            let accessed = file["accessed"] as! Bool
            
            let f = File(id: id, name: name, size: 0, icon: "", content_type: "video/mp4", has_mp4: true, parent_id: 0, subtitles: "", accessed: accessed, screenshot: screenshot, is_shared: false, start_from: start_from)
            
            return f
        }
        
        
        let show = TVShow()
        show.id = Int(cache["id"] as! String)
        show.title = cache["title"] as? String
        show.posterURL = cache["posterURL"] as? String
        show.overview = cache["overview"] as? String
        show.files = files
        
        return show
        
    }
    
}
