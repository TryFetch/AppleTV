//
//  MovieInfoViewController.swift
//  Fetch
//
//  Created by Stephen Radford on 14/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit
import AVKit

class MovieInfoViewController: UIViewController {

    @IBOutlet weak var backdrop: UIImageView!
    
    @IBOutlet weak var poster: UIImageView!
    
    @IBOutlet weak var overview: UITextView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var overviewHeight: NSLayoutConstraint!
    
    var file: File?
    
    var movie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = movie?.title
        overview.text = movie?.overview
        overviewHeight.constant = overview.contentSize.height
        
        if movie?.files.count == 1 {
            file = movie?.files[0]
        }
        
        file = movie?.files[0]
    
        loadBackdrop()
    }
    
    func loadBackdrop() {
        
        poster.layer.shadowColor = UIColor.blackColor().CGColor
        poster.layer.shadowOffset = CGSizeMake(0, 2)
        poster.layer.shadowRadius = 5
        poster.layer.shadowOpacity = 0.2
        
        if let poster = movie?.poster {
            
            self.poster.image = poster
            
            if let backdrop = movie?.backdrop {
                let image = backdrop
                self.backdrop.image = image
            } else {
                let image = self.blurImage(poster)
                self.backdrop.image = image
                self.movie?.backdrop = image
            }
            
            if poster.isDark() {
                self.titleLabel.textColor = .whiteColor()
                self.overview.textColor = .whiteColor()
            }
            
        } else if movie?.posterURL != nil {
            
            movie?.loadPoster { image in
                
                UIView.transitionWithView(self.poster, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                    self.poster.image = image
                }, completion: nil)

                UIView.transitionWithView(self.backdrop, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                    self.backdrop.image = self.blurImage(image)
                }, completion: nil)
                
                if image.isDark() {
                    self.titleLabel.textColor = .whiteColor()
                    self.overview.textColor = .whiteColor()
                }
                
            }
            
        }
        
    }
    
    func blurImage(image: UIImage) -> UIImage {
        
        let context = CIContext()
        
        let imageToBlur = CIImage(image: image)
        
        let clampFilter = CIFilter(name: "CIAffineClamp")
        clampFilter!.setDefaults()
        clampFilter!.setValue(imageToBlur, forKey: kCIInputImageKey)
        
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(40, forKey: "inputRadius")
        blurfilter!.setValue(imageToBlur, forKey: kCIInputImageKey)
        
        let resultImage = blurfilter!.valueForKey(kCIOutputImageKey) as! CIImage
        
        let rect = CGRectInset(imageToBlur!.extent, 40, 0)
        return UIImage(CGImage: context.createCGImage(resultImage, fromRect: rect)!)
        
    }

    
    @IBAction func play(sender: AnyObject) {
        movie?.files[0].getTime {
            self.performSegueWithIdentifier("showPlayer", sender: sender)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let videoController: MediaPlayerViewController = segue.destinationViewController as! MediaPlayerViewController
        videoController.file = file
        let urlString = "\(Putio.api)files/\(file!.id)/hls/media.m3u8?oauth_token=\(Putio.accessToken!)&subtitle_key=default"
        let url = NSURL(string: urlString)
        let video = AVPlayerItem(URL: url!)
        
        if let image = movie!.poster {
            let artwork = AVMutableMetadataItem()
            artwork.key = AVMetadataCommonKeyArtwork
            artwork.keySpace = AVMetadataKeySpaceCommon
            artwork.value = UIImagePNGRepresentation(image)
            artwork.locale = NSLocale.currentLocale()
            video.externalMetadata.append(artwork)
        }
        
        if let epTitle = movie!.title {
            let title = AVMutableMetadataItem()
            title.key = AVMetadataCommonKeyTitle
            title.keySpace = AVMetadataKeySpaceCommon
            title.value = epTitle
            title.locale = NSLocale.currentLocale()
            video.externalMetadata.append(title)
        }
        
        if let overview = movie!.overview {
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
