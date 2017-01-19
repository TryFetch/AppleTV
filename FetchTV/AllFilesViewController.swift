//
//  AllFilesViewController.swift
//  Fetch
//
//  Created by Stephen Radford on 19/10/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit
import AVFoundation
import Alamofire

class AllFilesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var directory: File?
    
    var selectedFile: File?
    
    var files: [File] = []
    
    var tableView: UITableView!
    
    var infoView: GenericFileInfoViewController!
    
    var noMediaView: NoMediaView?
    
    var loadingView: LoadingView?
    
    var loaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noMediaView = NSBundle.mainBundle().loadNibNamed("NoMediaView", owner: self, options: nil)![0] as? NoMediaView
        noMediaView?.label.text = "No Files Available"
        noMediaView?.frame = view.bounds
        noMediaView?.hidden = true
        view.addSubview(noMediaView!)
        
        loadingView = NSBundle.mainBundle().loadNibNamed("LoadingView", owner: self, options: nil)![0] as? LoadingView
        loadingView!.frame = view.bounds
        loadingView!.activityIndicator.startAnimating()
        loadingView!.hidden = true
        view.addSubview(loadingView!)
        
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(0.5) * Double(NSEC_PER_SEC)))
        
        dispatch_after(dispatch_time_t(delay), dispatch_get_main_queue()) {
            if !self.loaded {
                self.loadingView?.alpha = 0
                self.loadingView?.hidden = false
                UIView.animateKeyframesWithDuration(1.0, delay: 0, options: [], animations: {
                    self.loadingView?.alpha = 1
                }, completion: nil)
            }
        }
        
        navigationItem.title = (directory != nil) ? directory!.name : "All Files"
        let rect = CGRectMake(90, 0, view.bounds.width-180, 145)
        navigationController?.navigationBar.frame = rect
        
        infoView.view.hidden = true
        
        loadFiles()
    }
    
    func loadFiles() {
        var params = ["oauth_token" : Putio.accessToken!, "start_from": "1"]
        if directory != nil {
            params["parent_id"] = "\(directory!.id)"
        }
        
        Files.fetchMoviesFromURL("\(Putio.api)files/list", params: params, sender: self) { files in
            self.files = files
            self.tableView.reloadData()
            self.loaded = true
            
            if files.count == 0 {
                self.noMediaView?.hidden = false
            } else {
                self.infoView.view.hidden = false
            }
            
            if !self.loadingView!.hidden {
                UIView.animateKeyframesWithDuration(1.0, delay: 0.5, options: [], animations: {
                    self.loadingView?.alpha = 0
                }, completion: { complete in
                    self.loadingView?.hidden = true
                })
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("fileCell")!
        cell.textLabel?.text = files[indexPath.row].name
        cell.accessoryType = (files[indexPath.row].content_type == "application/x-directory") ? .DisclosureIndicator : .None
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedTable" {
            let vc = segue.destinationViewController as! AllFilesTableViewController
            tableView = vc.tableView
        }
        
        if segue.identifier == "embedGenericView" {
            let vc = segue.destinationViewController as! GenericFileInfoViewController
            infoView = vc
        }
        
        if segue.identifier == "showPlayer" {
            let videoController: MediaPlayerViewController = segue.destinationViewController as! MediaPlayerViewController
            videoController.file = selectedFile
            let urlString = "\(Putio.api)files/\(selectedFile!.id)/hls/media.m3u8?oauth_token=\(Putio.accessToken!)&subtitle_key=default"
            let url = NSURL(string: urlString)
            videoController.player = AVPlayer(URL: url!)
        }
    }
    
    func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
        if let nextIndex = context.nextFocusedIndexPath {
            let file = files[nextIndex.row]
            infoView.titleLabel.text = file.name
            infoView.imageView.image = UIImage(named: "episode")
            infoView.subtitlesLabel.text = (file.subtitles.characters.count > 0) ? "Yes" : "No"
            infoView.fileSizeLabel.text = ""
            infoView.fileAccessedLabel.text = (file.accessed) ? "Yes" : "No"
            infoView.contentTypeLabel.text = file.content_type
            
            let formatter = NSByteCountFormatter()
            infoView.fileSizeLabel.text = formatter.stringFromByteCount(file.size)
            
            if let screenshot = file.screenshot where file.image == nil {
                Alamofire.request(.GET, screenshot)
                    .responseData { response in
                        let image = UIImage(data: response.result.value!)
                        file.image = image
                        UIView.transitionWithView(self.infoView.imageView, duration: 0.8, options: .TransitionCrossDissolve, animations: {
                            self.infoView.imageView.image = image
                        }, completion: nil)
                }
            } else if let image = file.image {
                infoView.imageView.image = image
            } else if file.content_type == "application/x-directory" {
                infoView.imageView.image = UIImage(named: "directory")
            }
            
        }
        
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let file = files[indexPath.row]
        
        if file.content_type == "application/x-directory" {
            let vc = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("filesView") as! AllFilesViewController
            vc.directory = files[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        } else {
            selectedFile = file
            performSegueWithIdentifier("showPlayer", sender: self)
        }
    
    }

}
