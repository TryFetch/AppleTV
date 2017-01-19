//
//  FilesTableViewController.swift
//  Fetch
//
//  Created by Stephen Radford on 11/09/2015.
//  Copyright © 2015 Cocoon Development Ltd. All rights reserved.
//

import UIKit
import PutioKit
import AVKit
import Alamofire

class FilesTableViewController: UITableViewController {
    
    var files: [File] = []
    
    var selectedFile: File?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(Putio.api)files/list")
        
        Files.fetchWithURL("\(Putio.api)files/list", params: ["oauth_token": Putio.accessToken!], sender: self) { files in
            self.files = files
            self.tableView.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return files.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("file", forIndexPath: indexPath)

        cell.textLabel?.text = files[indexPath.row].name

        return cell
    }

    
    // MARK: - Navigation
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedFile = files[indexPath.row]
        print(selectedFile)
    }
    
    override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        selectedFile = files[indexPath.row]
        loadImage()
    }
    
    override func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
        loadImage()
    }
    
    func loadImage() {
        
        if selectedFile?.screenshot != nil {
            print(selectedFile!.screenshot!)
            
            Alamofire.request(.GET, selectedFile!.screenshot!)
                .responseData { _, _, result in
                    let parent = self.parentViewController as! FilesViewController
                    
                    print(result.value)
                    
                    UIView.transitionWithView(parent.backgroundView, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                        parent.backgroundView.image = UIImage(data: result.value!)
                    }, completion: nil)
                    
                }
        }
        
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let videoController: MediaPlayerViewController = segue.destinationViewController as! MediaPlayerViewController
        videoController.file = selectedFile
        
        var urlString: String!
        
        urlString = "\(Putio.api)files/308534337/hls/media.m3u8?oauth_token=\(Putio.accessToken!)&subtitle_key=default"
        
        let url = NSURL(string: urlString)
        videoController.player = AVPlayer(URL: url!)
    }


}
