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
import youtube_ios_player_helper

class VideoListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    var dataController: DataController!
    var channel : YouTubeChannel!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var videos : [YouTubeVideo] = []
    var lastVideoIdUsed : String = ""
    
    
    // MARK: Outlets
    @IBOutlet weak var videoTableView: UITableView!
    @IBOutlet weak var videoPlayer: YTPlayerView!
    
    // MARK: Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        videoTableView.dataSource = self
        videoTableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()
//        let predicate = NSPredicate(format: "videoToChannel == %@", channel)
//        fetchRequest.predicate = predicate
//        let sortDescriptor = NSSortDescriptor(key: "videoID", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
        
//        if let result = try? dataController.viewContext.fetch(fetchRequest) {
//            if result.count == 0 {
//                displayVideosFromChannel(channel.channelID!)
//            } else {
//                videos = result
//            }
//        }
        
        displayVideosFromChannel(channel.channelID!)
    }
    
    // MARK: Helper Methods
    private func displayVideosFromChannel(_ video: String){
        
        YouTubeClient.sharedInstance().getVideosFromChannel(video){(results, error) in
            guard error == nil else {
                // TODO: Take the error and display an error message on the screen
                return
            }
            
            // TODO: we should unwrap results rather than '!'
            //var videoArray = [Video]()
            for video in results! {
                //print("The results are: \(results)")
                var newVideo = YouTubeVideo()
                
                if let idObject = video[YouTubeClient.JSONBodyResponse.Id] as? [String: AnyObject]{
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
                print("-------The new Video is : \(newVideo)")
                self.videos.append(newVideo)
                print("--------------in loop video array: \(self.videos)")
                //try? self.dataController.viewContext.save()
                //videoArray.append(newVideo)
            }
            
//            let fetchRequest : NSFetchRequest<Video> = Video.fetchRequest()
//            let predicate = NSPredicate(format: "videoToChannel == %@", self.channel)
//            fetchRequest.predicate = predicate
//            let sortDescriptor = NSSortDescriptor(key: "videoID", ascending: true)
//            fetchRequest.sortDescriptors = [sortDescriptor]
//            if let results = try? self.dataController.viewContext.fetch(fetchRequest){
//                self.videos = results
//            }
            print("------------------VIdeoArray is: \(self.videos)")
            //self.videos = videoArray
            performUIUpdatesOnMain {
                self.videoTableView.reloadData()
                self.lastVideoIdUsed = self.videos[0].videoID!
                self.videoPlayer.load(withVideoId: self.lastVideoIdUsed)
            }
            //print(results as Any)
        }
    }
   
}

// MARK: TableView Delegate Methods
extension VideoListViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "VideoTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? VideoTableViewCell
        
        // TODO: Decorate the cell
        cell?.videoTitle?.text = videos[(indexPath as NSIndexPath).row].videoTitle
        cell?.videoDescription?.text = videos[(indexPath as NSIndexPath).row].videoDescription
        cell?.detailTextLabel?.numberOfLines = 2
        
        if videos[(indexPath as NSIndexPath).row].videoThumbnailDefaultData == nil {
            //            cell?.imageView?.image = UIImage(named: "placeholder")
            //            cell.activityIndicator.isHidden = false
            //            cell.activityIndicator.startAnimating()
            
            DispatchQueue.main.async() {
                let image = try! UIImage(data: Data(contentsOf: URL(string: (self.videos[(indexPath as NSIndexPath).row].videoThumbnailDefaultURL)!)!))
                self.videos[(indexPath as NSIndexPath).row].videoThumbnailDefaultData = UIImagePNGRepresentation(image!)
                //try? self.dataController.viewContext.save()
                
                performUIUpdatesOnMain {
                    cell?.videoImage?.image = image
                    cell?.videoTitle?.text = self.videos[(indexPath as NSIndexPath).row].videoTitle
                    cell?.videoDescription?.text = self.videos[(indexPath as NSIndexPath).row].videoDescription
                    self.videoTableView.reloadData()
                }
            }
        } else {
            let image = UIImage(data: (videos[(indexPath as NSIndexPath).row].videoThumbnailDefaultData)! as Data)
            cell?.videoImage?.image = image
            cell?.videoTitle?.text = videos[(indexPath as NSIndexPath).row].videoTitle
            cell?.videoDescription?.text = videos[(indexPath as NSIndexPath).row].videoDescription
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastVideoIdUsed = videos[(indexPath as IndexPath).row].videoID!
        videoPlayer.load(withVideoId: lastVideoIdUsed)
        //videoPlayer.playVideo()
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
}
