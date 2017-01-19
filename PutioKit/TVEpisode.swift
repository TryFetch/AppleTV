//
//  Episode.swift
//  Fetch
//
//  Created by Stephen Radford on 10/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import Alamofire

public class TVEpisode {
    
    /// the tmdb ID
    public var id: Int?
    
    /// the epsiode number in the tv series
    public var episodeNo: Int?
    
    /// the title of the episode
    public var title: String?
    
    /// the description of the episode
    public var overview: String?
    
    /// the season the episode is in
    public var seasonNo: Int?
    
    /// link to the sill
    public var stillURL: String?
    
    /// Original Air date
    public var airDate: String?
    
    /// the putio file accompanying this tv episode
    public var file: File?
    
    /// Still image
    public var still: UIImage?
    
    /// Load the movie poster
    public func loadStill(callback: (UIImage) -> Void) {
        if let url = stillURL {
            Alamofire.request(.GET, "https://image.tmdb.org/t/p/w780\(url)")
                .responseImage { response in
                    if let image = response.result.value {
                        self.still = image
                        callback(image)
                    }
                }
            
        } else if let url = file?.screenshot {
            Alamofire.request(.GET, "\(url)")
                .responseImage { response in
                    if let image = response.result.value {
                        self.still = image
                        callback(image)
                    }
                }
        }
        
    }
    
}
