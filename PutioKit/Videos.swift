//
//  Videos.swift
//  Fetch
//
//  Created by Stephen Radford on 10/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Downpour
#if os(tvOS)
import TVServices
#endif

public class Videos {
    
    /// Parsed movies from tmdb
    public var movies: [Movie] = []
    
    /// Parsed tv shows from tmdb
    public var tvShows: [TVShow] = []
    
    /// New movies just found on TMDB
    private var newMovies: [Movie] = []
    
    /// New TV just found on TMDB
    private var newTvShows: [TVShow] = []
    
    /// Movies sorted alphabetically
    public var sortedMovies: [Movie] {
        get {
           return self.movies.sort({ $0.sortableTitle < $1.sortableTitle })
        }
    }

    /// TV shows sorted alphabetically
    public var sortedTV: [TVShow] {
        get {
            return self.tvShows.sort({ $0.sortableTitle < $1.sortableTitle })
        }
    }
    
    /// The flattened out raw files from put.io
    public var files: [File] = []
    
    /// The old raw files
    public var oldFiles: [File] = []
    
    /// The shared instances of our lovely video class
    public static let sharedInstance = Videos()
    
    /// Recursive method count
    private var folderCount = 0
    
    /// Search Terms
    private var searches: [String:TMDBSearch] = [:]
    
    private var completed = 0
    
    public var syncing = false
    
    public var completedPercent: Float {
        get {
            return (Float(self.completed) / Float(self.searches.count))
        }
    }
    
    init() {
        
        if let cachedMovies = NSUserDefaults(suiteName: "group.FetchPutIo")?.objectForKey("movies") as? [[String:AnyObject]] {
            for m in cachedMovies {
                movies.append(Movie.fromCache(m))
            }
        }
        
        if let cachedShows = NSUserDefaults(suiteName: "group.FetchPutIo")?.objectForKey("shows") as? [[String:AnyObject]] {
            for s in cachedShows {
                tvShows.append(TVShow.fromCache(s))
            }
        }
        
    }
    
    // MARK: - Putio
    
    /**
     Start fetching files and folders from Put.io
     */
    public func fetch() {
        
        guard !syncing else {
            print("already syncing")
            return
        }
        
        syncing = true
        
        // Wipe everything!
        if files.count > 0 || movies.count > 0 || tvShows.count > 0 {
            oldFiles = files
            searches = [:]
            files = []
        }
        
        let params = ["oauth_token": "\(Putio.accessToken!)", "start_from": "1"]
        Alamofire.request(.GET, "\(Putio.api)files/list", parameters: params)
            .responseJSON { response in
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)
                    let files = json["files"].array!.map(self.parseFile)
                    self.recursivelyFetchFiles(files)
                }
            }
    }
    
    /**
     Recursively fetch files from the original root results
     
     - parameter files: Files to fetch
     */
    private func recursivelyFetchFiles(files: [File]) {
        self.files.appendContentsOf(files)
        for file in files {
            
            if file.is_shared {
                continue
            }
            
            if file.content_type == "application/x-directory" {
                folderCount += 1
                loadSubfolderFromFile(file) { files in
                    self.folderCount -= 1
                    self.recursivelyFetchFiles(files)
                }
            }
        }
        
        if folderCount == 0 && movies.count == 0 && tvShows.count == 0 { // This is the first run
            print("Finished fetching files")
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "PutioFinished", object: self))
            convertToSearchTerms()
        } else if folderCount == 0 { // This is a refresh
            print("Finished re-fetching files")
            if self.files.count != oldFiles.count {
                print("File count changed!")
                convertToSearchTerms()
            } else {
                syncing = false
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "RefreshComplete", object: self))
            }
        }
    }
    
    /**
     Load a subfolder by using the parent_id from the file provided
     
     - parameter file:     The folder to fetch
     - parameter callback: Called when Alamofire has finished
     */
    private func loadSubfolderFromFile(file: File, callback: ([File]) -> Void) {
        guard Putio.accessToken != nil else {
            print("Logged out")
            return
        }
        
        let params = ["oauth_token": "\(Putio.accessToken!)", "parent_id": "\(file.id)", "start_from": "1"]
        Alamofire.request(.GET, "\(Putio.api)files/list", parameters: params)
            .responseJSON { response in
                
                if response.result.isSuccess {
                
                    let json = JSON(response.result.value!)
                    let files = json["files"].array!.map(self.parseFile)
                    for f in files {
                        f.parent = file
                    }
                
                    callback(files)
                
                }
        }
    }
    
    /**
     Map JSON to a file
     
     - parameter f: JSON to map
     
     - returns: File
     */
    private func parseFile(f: JSON) -> File {
        let subtitles = ""
        let accessed = ( f["first_accessed_at"].null != nil ) ? false : true
        let start_from = ( f["start_from"].null != nil ) ? 0 : f["start_from"].double!
        let has_mp4 = (f["is_mp4_available"].bool != nil) ? f["is_mp4_available"].bool! : false
        
        let file = File(id: f["id"].int32!, name: f["name"].string!, size: f["size"].int64!, icon: f["icon"].string!, content_type: f["content_type"].string!, has_mp4: has_mp4, parent_id: f["parent_id"].int32!, subtitles: subtitles, accessed: accessed, screenshot: f["screenshot"].string, is_shared: f["is_shared"].bool!, start_from: start_from)
        
        file.created_at = f["created_at"].string
        return file
    }
    
    // MARK: - TMDB
    
    /**
    Convert names to proper search terms
    */
    private func convertToSearchTerms() {
        
        for file in files {
            
            if file.has_mp4 || file.content_type == "video/mp4" {
                
                let d = Downpour(string: file.name)
  
                if let search = searches[d.title.lowercaseString] {
                    search.files.append(file)
                } else {
                    let search = TMDBSearch()
                    search.downpour = d
                    search.files.append(file)
                    searches[d.title.lowercaseString] = search
                }

                // Searching parents may be overkill especially as people double nest
//                if file.parent != nil {
//                    let d = Downpour(string: file.parent!.name)
//                    if searches[d.title] != nil {
//                        searches[d.title]!.append(file)
//                    } else {
//                        searches[d.title] = [file]
//                    }
//                }
                
            }

        }
        
        print("Searching TMDB")
        searchTMDB()
        
    }
    
    /**
     Search the TMDB
     */
    func searchTMDB() {
        
        folderCount = 0
        TMDB.sharedInstance.requests = 0
        newMovies = []
        newTvShows = []
        
        for term in searches {
            folderCount += 1
            
            func parseResult(result: (movie: Movie?, tvshow: TVShow?)) {
                
                self.folderCount -= 1
                self.completed += 1
                
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "TMDBUpdated", object: self))
                
                if let tvshow = result.tvshow {
                    tvshow.files = term.1.files
                    self.newTvShows.append(tvshow)
                }
                
                if let movie = result.movie {
                    movie.files = term.1.files
                    self.newMovies.append(movie)
                }
                
                if self.folderCount == 0 {
                    print("TMDB Search Complete")
                    
                    // Set movies to be the new movies from the fetch/refresh
                    self.movies = self.newMovies
                    self.tvShows = self.newTvShows

                    TMDB.sharedInstance.requests = 0
                    
                    #if os(tvOS)
                    saveToDefaults()
                    #endif
                    
                    syncing = false
                    
                    // Tell the App it's all done
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "TMDBFinished", object: self))
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "RefreshComplete", object: self))
                    
                }
                
            }
            
            if term.1.downpour?.type == .Movie {
                TMDB.searchMoviesWithString(term.0, year: term.1.downpour?.year, callback: parseResult)
            } else {
                TMDB.searchTVWithString(term.0, year: term.1.downpour?.year, callback: parseResult)
            }
            
            
        }
        
    }
    
    #if os(tvOS)
    func saveToDefaults() {
        // Save it to the app group for use in the TopShelfExtension
        if let defaults = NSUserDefaults(suiteName: "group.FetchPutIo") {
            
            let sorted = movies.sort({ $0.files[0].created_at! > $1.files[0].created_at! })
            
            let mArray: [[String:AnyObject]] = sorted.map {
                
                let files: [[String:AnyObject]] = $0.files.map { file in
                    return [
                        "id": Int(file.id),
                        "name": file.name,
                        "accessed": file.accessed,
                        "start_from": file.start_from,
                        "screenshot": (file.screenshot != nil) ? file.screenshot! : ""
                    ]
                }
                
                return [
                    "id": "\($0.id!)",
                    "posterURL": ($0.posterURL != nil) ? $0.posterURL! : "",
                    "title": ($0.title != nil) ? $0.title! : "",
                    "overview": ($0.overview != nil) ? $0.overview! : "",
                    "files": files
                ]
            }
            
            
            let sortedTV = tvShows.sort({ $0.files[0].created_at! > $1.files[0].created_at! })
            
            let tArray: [[String:AnyObject]] = sortedTV.map {
                
                let files: [[String:AnyObject]] = $0.files.map { file in
                    return [
                        "id": Int(file.id),
                        "name": file.name,
                        "accessed": file.accessed,
                        "start_from": file.start_from,
                        "screenshot": (file.screenshot != nil) ? file.screenshot! : ""
                    ]
                }
                
                return [
                    "id": "\($0.id!)",
                    "posterURL": ($0.posterURL != nil) ? $0.posterURL! : "",
                    "title": ($0.title != nil) ? $0.title! : "",
                    "overview": ($0.overview != nil) ? $0.overview! : "",
                    "files": files
                ]
            }
            
            defaults.setObject(mArray, forKey: "movies")
            defaults.setObject(tArray, forKey: "shows")
            defaults.synchronize()
            
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name:
                TVTopShelfItemsDidChangeNotification, object: nil))
        }
    }
    #endif
  
    
    /// Atomically wipe the shared instance
    public func wipe() {
        tvShows = []
        files = []
        movies = []
        searches = [:]
        
        #if os(tvOS)
        if let defaults = NSUserDefaults(suiteName: "group.FetchPutIo") {
            defaults.setObject(nil, forKey: "movies")
            defaults.setObject(nil, forKey: "shows")
            defaults.synchronize()
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name:
                TVTopShelfItemsDidChangeNotification, object: nil))
        }
        #endif
    }

    
}
