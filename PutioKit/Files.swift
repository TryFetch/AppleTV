//
//  Files.swift
//  Fetch
//
//  Created by Stephen Radford on 08/08/2015.
//  Copyright (c) 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

public class Files {
    
    
    /// Fetch an array of files from a specific URL
    public class func fetchWithURL(url: String, params: [String:String], sender: UIViewController, callback: ([File]) -> Void) {
        
        Putio.networkActivityIndicatorVisible(true)
        
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { response in
                
                Putio.networkActivityIndicatorVisible(false)
                
                if(response.response?.statusCode >= 400 && response.response?.statusCode < 500) {
                    Putio.sharedInstance.delegate?.error400Received()
                    return
                }
                
                var files: [File] = []
                
                if let error = response.result.error {
                    print(error)
                } else {
                    var json = JSON(response.result.value!)
                    
                    for (_, jFile): (String, JSON) in json["files"] {
                        
                        let subtitles = ( jFile["opensubtitles_hash"].null != nil ) ? "" : jFile["opensubtitles_hash"].string!
                        let accessed = ( jFile["first_accessed_at"].null != nil ) ? false : true
                        let start_from = ( jFile["start_from"].null != nil ) ? 0 : jFile["start_from"].double!
                        let has_mp4 = (jFile["is_mp4_available"].bool != nil) ? jFile["is_mp4_available"].bool! : false
                        
                        let file = File(id: jFile["id"].int32!, name: jFile["name"].string!, size: jFile["size"].int64!, icon: jFile["icon"].string!, content_type: jFile["content_type"].string!, has_mp4: has_mp4, parent_id: jFile["parent_id"].int32!, subtitles: subtitles, accessed: accessed, screenshot: jFile["screenshot"].string, is_shared: jFile["is_shared"].bool!, start_from: start_from)
                        
                        file.created_at = jFile["created_at"].string
                        
                        files.append(file)
                        
                    }

                }
                
                callback(files)
                
            }
    
    }
    
    public class func fetchMoviesFromURL(url: String, params: [String:String], sender: UIViewController, callback: ([File]) -> Void) {
        
        Putio.networkActivityIndicatorVisible(true)
        
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { response in
                
                Putio.networkActivityIndicatorVisible(false)
                
                if(response.response?.statusCode >= 400 && response.response?.statusCode < 500) {
                    Putio.sharedInstance.delegate?.error400Received()
                    return
                }
                
                var files: [File] = []
                
                if let error = response.result.error {
                    print(error)
                } else {
                    var json = JSON(response.result.value!)
                    
                    for (_, jFile): (String, JSON) in json["files"] {
                       
                        
                        let subtitles = ( jFile["opensubtitles_hash"].null != nil ) ? "" : jFile["opensubtitles_hash"].string!
                        let accessed = ( jFile["first_accessed_at"].null != nil ) ? false : true
                        let start_from = ( jFile["start_from"].null != nil ) ? 0 : jFile["start_from"].double!
                        let has_mp4 = (jFile["is_mp4_available"].bool != nil) ? jFile["is_mp4_available"].bool! : false
                        
                        if !has_mp4 && jFile["content_type"] != "application/x-directory" && jFile["content_type"] != "video/mp4"  {
                            continue
                        }
                        
                        
                        let file = File(id: jFile["id"].int32!, name: jFile["name"].string!, size: jFile["size"].int64!, icon: jFile["icon"].string!, content_type: jFile["content_type"].string!, has_mp4: has_mp4, parent_id: jFile["parent_id"].int32!, subtitles: subtitles, accessed: accessed, screenshot: jFile["screenshot"].string, is_shared: jFile["is_shared"].bool!, start_from: start_from)
                        
                        file.created_at = jFile["created_at"].string
                        
                        files.append(file)
                        
                    }
                    
                }
                
                callback(files)
                
        }
        
    }
    
    
    /// Fetch an array of folders from a specific URL
    public class func fetchFoldersFromURL(url: String, params: [String:String], callback: ([File]) -> Void) {
        
        Putio.networkActivityIndicatorVisible(true)
        
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { response in
                
                Putio.networkActivityIndicatorVisible(false)
                
                var files: [File] = []
                
                if let error = response.result.error {
                    print(error)
                } else {
                    var json = JSON(response.result.value!)
                    
                    for (_, jFile): (String, JSON) in json["files"] {
                        
                        if jFile["content_type"].string! != "application/x-directory" || jFile["is_shared"].bool! {
                            continue
                        }
                        
                        let subtitles = ( jFile["opensubtitles_hash"].null != nil ) ? "" : jFile["opensubtitles_hash"].string!
                        let accessed = ( jFile["first_accessed_at"].null != nil ) ? false : true
                        let start_from = ( jFile["start_from"].null != nil ) ? 0 : jFile["start_from"].double!
                        
                        let file = File(id: jFile["id"].int32!, name: jFile["name"].string!, size: jFile["size"].int64!, icon: jFile["icon"].string!, content_type: jFile["content_type"].string!, has_mp4: jFile["is_mp4_available"].bool!, parent_id: jFile["parent_id"].int32!, subtitles: subtitles, accessed: accessed, screenshot: jFile["screenshot"].string, is_shared: jFile["is_shared"].bool!, start_from: start_from)
                        
                        file.created_at = jFile["created_at"].string
                        
                        files.append(file)
                        
                    }
                }
                
                callback(files)
                
            }
        
    }
    
    /// Fetch an array of folders from a specific URL but exclude a file
    public class func fetchFoldersWithExclusionFromURL(url: String, params: [String:String], exclude: File?, callback: ([File]) -> Void) {
        
        Putio.networkActivityIndicatorVisible(true)
        
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { response in
                
                Putio.networkActivityIndicatorVisible(false)
                
                var files: [File] = []
                
                if let error = response.result.error {
                    print(error)
                } else {
                    var json = JSON(response.result.value!)
                    
                    for (_, jFile): (String, JSON) in json["files"] {
                        
                        if jFile["content_type"].string! != "application/x-directory" || jFile["is_shared"].bool! || (exclude != nil && jFile["id"].int32! == exclude!.id) {
                            continue
                        }
                        
                        let subtitles = ( jFile["opensubtitles_hash"].null != nil ) ? "" : jFile["opensubtitles_hash"].string!
                        let accessed = ( jFile["first_accessed_at"].null != nil ) ? false : true
                        let start_from = ( jFile["start_from"].null != nil ) ? 0 : jFile["start_from"].double!
                        let has_mp4 = (jFile["is_mp4_available"].bool != nil) ? jFile["is_mp4_available"].bool! : false
                        
                        let file = File(id: jFile["id"].int32!, name: jFile["name"].string!, size: jFile["size"].int64!, icon: jFile["icon"].string!, content_type: jFile["content_type"].string!, has_mp4: has_mp4, parent_id: jFile["parent_id"].int32!, subtitles: subtitles, accessed: accessed, screenshot: jFile["screenshot"].string, is_shared: jFile["is_shared"].bool!, start_from: start_from)
                        
                        file.created_at = jFile["created_at"].string
                        
                        files.append(file)
                        
                    }

                }
                
                
                callback(files)
                
        }
        
    }
    
}