//
//  VideoListViewController.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 5/5/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class VideoListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    var dataController: DataController!
    var channel : Channel!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var videos : [Video]?
    
    
    // MARK: Outlets
    @IBOutlet weak var videoTableView: UITableView!
    
    // MARK: Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        videoTableView.dataSource = self
        videoTableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()
        let predicate = NSPredicate(format: "videoToChannel == %@", channel)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "videoID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            if result.count == 0 {
                displayVideosFromChannel(channel.channelID!)
            } else {
                videos = result
            }
        }
    }
    
    // MARK: Helper Methods
    private func displayVideosFromChannel(_ video: String){
        
        YouTubeClient.sharedInstance().getVideosFromChannel(appDelegate.user, video){(results, error) in
            guard error == nil else {
                // TODO: Take the error and display an error message on the screen
                return
            }
            
            // TODO: we should unwrap results rather than '!'
            //var videoArray = [Video]()
            for video in results! {
                let newVideo = Video(context: self.dataController.viewContext)
                
                if let idObject = video[YouTubeClient.JSONBodyResponse.CategoryId] as? [String: AnyObject]{
                    newVideo.videoID = idObject[YouTubeClient.JSONBodyResponse.VideoId] as? String
                }
                
                if let snippet = video[YouTubeClient.JSONBodyResponse.Snippet] as? [String:AnyObject] {
                    newVideo.videoDescription = snippet[YouTubeClient.JSONBodyResponse.Description] as? String
                    newVideo.videoTitle = snippet[YouTubeClient.JSONBodyResponse.Title] as? String
                    
                    if let thumbnails = snippet[YouTubeClient.JSONBodyResponse.Thumbnails] as? [String: AnyObject] {
                        if let defaultURL = thumbnails[YouTubeClient.JSONBodyResponse.Default] as? [String: AnyObject] {
                            newVideo.videoThumbnailDefaultURL = defaultURL[YouTubeClient.JSONBodyResponse.URL] as? String
                        }
                    }
                }
                newVideo.videoToChannel = self.channel
                try? self.dataController.viewContext.save()
                //videoArray.append(newVideo)
            }
            
            let fetchRequest : NSFetchRequest<Video> = Video.fetchRequest()
            let predicate = NSPredicate(format: "videoToChannel == %@", self.channel)
            fetchRequest.predicate = predicate
            let sortDescriptor = NSSortDescriptor(key: "videoID", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            if let results = try? self.dataController.viewContext.fetch(fetchRequest){
                self.videos = results
            }
            
            //self.videos = videoArray
            performUIUpdatesOnMain {
                self.videoTableView.reloadData()
            }
            //print(results as Any)
        }
    }
   
}

// MARK: TableView Delegate Methods
extension VideoListViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "VideoTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)
        
        // TODO: Decorate the cell
        cell?.textLabel?.text = videos?[(indexPath as NSIndexPath).row].videoTitle
        cell?.detailTextLabel?.text = videos?[(indexPath as NSIndexPath).row].description
        
        if videos?[(indexPath as NSIndexPath).row].videoThumbnailDefaultData == nil {
            //            cell?.imageView?.image = UIImage(named: "placeholder")
            //            cell.activityIndicator.isHidden = false
            //            cell.activityIndicator.startAnimating()
            
            DispatchQueue.main.async() {
                let image = try! UIImage(data: Data(contentsOf: URL(string: (self.videos?[(indexPath as NSIndexPath).row].videoThumbnailDefaultURL)!)!))
                self.videos?[(indexPath as NSIndexPath).row].videoThumbnailDefaultData = UIImagePNGRepresentation(image!)
                try? self.dataController.viewContext.save()
                
                performUIUpdatesOnMain {
                    cell?.imageView?.image = image
                    self.videoTableView.reloadData()
                }
            }
        } else {
            let image = UIImage(data: (videos?[(indexPath as NSIndexPath).row].videoThumbnailDefaultData)! as Data)
            cell?.imageView?.image = image
        }
        
//        getDataFromUrl(url: URL(string: (videos?[(indexPath as NSIndexPath).row].videoThumbnailDefaultURL)!)!) { (data, response, error) in
//            guard let data = data, error == nil else{
//                return
//            }
//            performUIUpdatesOnMain {
//                cell?.imageView?.image = UIImage(data: data)
//                self.videoTableView.reloadData()
//            }
//        }
        
        return cell!
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
}
