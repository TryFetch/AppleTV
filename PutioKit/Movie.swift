//
//  Movie.swift
//  Fetch
//
//  Created by Stephen Radford on 10/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

public class Movie {
    
    public var id: Int?
    
    /// URL to the backdrop on the API
    public var backdropURL: String?
    
    /// The backdrop of the image
    public var backdrop: UIImage?
    
    /// URL to the poster on the API
    public var posterURL: String?
    
    /// The poster image
    public var poster: UIImage?
    
    public var budget: Float64?
    
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
    
    public var genres: [Genre]?
    
    public var overview: String?
    
    public var releaseDate: String?
    
    public var runtime: Float64?
    
    public var tagline: String?
    
    public var voteAverage: Float64?
    
    /// Putio Files
    public var files: [File] = []
    
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
            
            var params = ["title": title!]
            if let year = releaseDate {
                params["year"] = year
            }
            
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
    
    
    public class func fromCache(cache: [String:AnyObject]) -> Movie {
        
        
        let files: [File] = (cache["files"] as! [[String:AnyObject]]).map { file in
            
            let id = Int32(file["id"] as! Int)
            let name = file["name"] as! String
            let screenshot = file["screenshot"] as! String
            let start_from = file["start_from"] as! Double
            let accessed = file["accessed"] as! Bool
            
            let f = File(id: id, name: name, size: 0, icon: "", content_type: "video/mp4", has_mp4: true, parent_id: 0, subtitles: "", accessed: accessed, screenshot: screenshot, is_shared: false, start_from: start_from)
            
            return f
        }
        
        let movie = Movie()
        movie.id = Int(cache["id"] as! String)
        movie.title = cache["title"] as? String
        movie.posterURL = cache["posterURL"] as? String
        movie.overview = cache["overview"] as? String
        movie.files = files
        
        return movie
        
    }
    
}
