//
//  File.swift
//  Fetch
//
//  Created by Stephen Radford on 17/05/2015.
//  Copyright (c) 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

public class File: NSObject {
   
    public var id: Int32
    public var name: String
    public var size: Int64
    public var icon: String
    public var content_type: String
    public var has_mp4: Bool
    public var parent_id: Int32
    public var subtitles: String
    public var accessed: Bool
    public var screenshot: String?
    public var is_shared: Bool
    public var start_from: Float64
    public var parent: File?
    public var type: String?
    public var image: UIImage?
    public var created_at: String?
    
    init(id: Int32, name: String, size: Int64, icon: String, content_type: String, has_mp4: Bool, parent_id: Int32, subtitles: String, accessed: Bool, screenshot: String?, is_shared: Bool, start_from: Double) {
        self.id = id
        self.name = name
        self.size = size
        self.icon = icon
        self.content_type = content_type
        self.has_mp4 = has_mp4
        self.parent_id = parent_id
        self.subtitles = subtitles
        self.accessed = accessed
        self.screenshot = screenshot
        self.is_shared = is_shared
        self.start_from = start_from
    }
    
    // MARK: - Delete File
    
    public func destroy() {
        Putio.networkActivityIndicatorVisible(true)
        
        let params = ["oauth_token": "\(Putio.accessToken!)", "file_ids": "\(id)"]
        
        Alamofire.request(.POST, "\(Putio.api)files/delete", parameters: params)
            .responseJSON { response in
                Putio.networkActivityIndicatorVisible(false)
                if response.result.isFailure {
                    print(response.result.error)
                }
        }
    }
    
    // MARK: - Convert to MP4
    
    public func convertToMp4() {
        Putio.networkActivityIndicatorVisible(true)
        
        let params = ["oauth_token": "\(Putio.accessToken!)"]
        
        Alamofire.request(.POST, "\(Putio.api)files/\(id)/mp4", parameters: params)
            .responseJSON { response in
                Putio.networkActivityIndicatorVisible(false)
                if response.result.isFailure {
                    print(response.result.error)
                }
        }
    }
    
    // MARK: - Save the time
    
    public func saveTime() {
        Putio.networkActivityIndicatorVisible(true)
        
        let params = ["oauth_token": "\(Putio.accessToken!)", "time": "\(start_from)"]
        
        Alamofire.request(.POST, "\(Putio.api)files/\(id)/start-from/set", parameters: params)
            .responseJSON { _ in
                print("time saved")
                Putio.networkActivityIndicatorVisible(false)
            }
    }
    
    // MARK: - Rename
    
    public func renameWithAlert(alert: UIAlertController) {
        Putio.networkActivityIndicatorVisible(true)
        
        let textField = alert.textFields![0] 
        name = textField.text!
        
        let params = ["oauth_token": "\(Putio.accessToken!)", "file_id": "\(id)", "name": "\(name)"]
        
        Alamofire.request(.POST, "\(Putio.api)files/rename", parameters: params)
            .response { _, _, _, _ in
                Putio.networkActivityIndicatorVisible(false)
            }
    }
    
    // MARK: - Move
    
    public func moveTo(parentId: Int32) {
        Putio.networkActivityIndicatorVisible(true)
        
        let params = ["oauth_token": "\(Putio.accessToken!)", "file_ids": "\(id)", "parent_id": "\(parentId)"]
        
        Alamofire.request(.POST, "\(Putio.api)files/move", parameters: params)
            .responseJSON { _ in
                Putio.networkActivityIndicatorVisible(false)
            }
    }
    
    public func getTime(callback: () -> Void) {
        
        let params = ["oauth_token": "\(Putio.accessToken!)", "start_from": "1"]
        
        Alamofire.request(.GET, "\(Putio.api)files/\(id)", parameters: params)
            .responseJSON { response in
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)
                    if let time = json["file"]["start_from"].double {
                        self.start_from = time
                    }
                }
                
                callback()
            }
    }
    
    public class func getFileById(id: String, callback: (File) -> Void) {
        
        let params = ["oauth_token": "\(Putio.accessToken!)", "start_from": "1"]
        
        Alamofire.request(.GET, "\(Putio.api)files/\(id)", parameters: params)
            .responseJSON { response in
                if response.result.isSuccess {
                    let json = JSON(response.result.value!)
                    
                    let subtitles = ""
                    let accessed = ( json["file"]["first_accessed_at"].null != nil ) ? false : true
                    let start_from = ( json["file"]["start_from"].null != nil ) ? 0 : json["file"]["start_from"].double!
                    let has_mp4 = (json["file"]["is_mp4_available"].bool != nil) ? json["file"]["is_mp4_available"].bool! : false
                    
                    let file = File(id: json["file"]["id"].int32!, name: json["file"]["name"].string!, size: json["file"]["size"].int64!, icon: json["file"]["icon"].string!, content_type: json["file"]["content_type"].string!, has_mp4: has_mp4, parent_id: json["file"]["parent_id"].int32!, subtitles: subtitles, accessed: accessed, screenshot: json["file"]["screenshot"].string, is_shared: json["file"]["is_shared"].bool!, start_from: start_from)
                    
                    file.created_at = json["file"]["created_at"].string
                    
                    callback(file)
                    
                }
            }
    }
    
}
