import Foundation
import TVServices

class ServiceProvider: NSObject, TVTopShelfProvider {
    
    var topShelfStyle: TVTopShelfContentStyle {
        // Return desired Top Shelf style.
        return .Sectioned
    }
    
    var topShelfItems: [TVContentItem] {
        
        let wrapperID = TVContentIdentifier(identifier: "movies", container: nil)!
        let wrapperItem = TVContentItem(contentIdentifier: wrapperID)!
        var ContentItems = [TVContentItem]()
        
        if let movies = NSUserDefaults(suiteName: "group.FetchPutIo")?.objectForKey("movies") as? [[String:AnyObject]] {
            
            let these = (movies.count > 5) ? Array(movies[0..<5]) : movies
            
            for movie in these {
                
                let identifier = TVContentIdentifier(identifier: "movie", container: wrapperID)!
                let contentItem = TVContentItem(contentIdentifier: identifier)!
                
                if let url = movie["posterURL"] as? String where url != "" {
                    contentItem.imageURL = NSURL(string: "https://image.tmdb.org/t/p/w500\(url)")
                }
                
                contentItem.imageShape = .Poster
                contentItem.title = movie["title"] as? String
                contentItem.displayURL = NSURL(string: "FetchTV://movie/\(movie["id"] as! String)")!;
                contentItem.playURL = NSURL(string: "FetchTV://play/\(movie["files"]![0]!["id"] as! Int)")!;
                
                ContentItems.append(contentItem)

            }
        }
        
        
        // Section Details
        wrapperItem.title = "Movies"
        wrapperItem.topShelfItems = ContentItems
        
        
        let tvWrapperID = TVContentIdentifier(identifier: "tvshows", container: nil)!
        let tvWrapper = TVContentItem(contentIdentifier: tvWrapperID)!
        var tvItems = [TVContentItem]()
        
        if let shows = NSUserDefaults(suiteName: "group.FetchPutIo")?.objectForKey("shows") as? [[String:AnyObject]] {
            
            let these = (shows.count > 5) ? Array(shows[0..<5]) : shows
            
            for show in these {
                
                let identifier = TVContentIdentifier(identifier: "show", container: wrapperID)!
                let contentItem = TVContentItem(contentIdentifier: identifier)!
                
                if let url = show["posterURL"] as? String where url != "" {
                    contentItem.imageURL = NSURL(string: "https://image.tmdb.org/t/p/w500\(url)")
                }
                
                contentItem.imageShape = .Poster
                contentItem.title = show["title"] as? String
                contentItem.displayURL = NSURL(string: "FetchTV://tv/\(show["id"] as! String)")!;
                contentItem.playURL = NSURL(string: "FetchTV://tv/\(show["id"] as! String)")!;
                
                tvItems.append(contentItem)
            }
        }
        
        
        // Section Details
        tvWrapper.title = "TV Shows"
        tvWrapper.topShelfItems = tvItems
        
        return [tvWrapper, wrapperItem]

    }
}