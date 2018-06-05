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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        videoTableView.dataSource = self
        videoTableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayVideosFromChannel(channel.channelID!)
    }
    
    // MARK: Helper Methods
    private func displayVideosFromChannel(_ video: String){
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        YouTubeClient.sharedInstance().getVideosFromChannel(video){(results, error) in
            guard error == nil else {
                self.showAlert()
                performUIUpdatesOnMain {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            
            for video in results! {
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
            }
            
            print("------------------VIdeoArray is: \(self.videos)")
            performUIUpdatesOnMain {
                self.videoTableView.reloadData()
                self.lastVideoIdUsed = self.videos[0].videoID ?? ""
                self.videoPlayer.load(withVideoId: self.lastVideoIdUsed)
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "Network Error", message: "There is an issue with your internet connection.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        self.present(alert, animated: true, completion: nil)
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
        cell?.activityIndicator.startAnimating()
        
        // TODO: Decorate the cell
        cell?.videoTitle?.text = videos[(indexPath as NSIndexPath).row].videoTitle
        cell?.videoDescription?.text = videos[(indexPath as NSIndexPath).row].videoDescription
        cell?.detailTextLabel?.numberOfLines = 2
        
        if videos[(indexPath as NSIndexPath).row].videoThumbnailDefaultData == nil {
            
            DispatchQueue.main.async() {
                
                guard let image = try? UIImage(data: Data(contentsOf: URL(string: (self.videos[(indexPath as NSIndexPath).row].videoThumbnailDefaultURL)!)!)) else {
                    self.showAlert()
                    return
                }
                
                self.videos[(indexPath as NSIndexPath).row].videoThumbnailDefaultData = UIImagePNGRepresentation(image!)
                
                performUIUpdatesOnMain {
                    cell?.videoImage?.image = image
                    cell?.videoTitle?.text = self.videos[(indexPath as NSIndexPath).row].videoTitle
                    cell?.activityIndicator.stopAnimating()
                    cell?.activityIndicator.isHidden = true
                    cell?.videoDescription?.text = self.videos[(indexPath as NSIndexPath).row].videoDescription
                    self.videoTableView.reloadData()
                }
            }
        } else {
            let image = UIImage(data: (videos[(indexPath as NSIndexPath).row].videoThumbnailDefaultData)! as Data)
            cell?.videoImage?.image = image
            cell?.videoTitle?.text = videos[(indexPath as NSIndexPath).row].videoTitle
            cell?.activityIndicator.stopAnimating()
            cell?.activityIndicator.isHidden = true
            cell?.videoDescription?.text = videos[(indexPath as NSIndexPath).row].videoDescription
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastVideoIdUsed = videos[(indexPath as IndexPath).row].videoID!
        videoPlayer.load(withVideoId: lastVideoIdUsed)
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
}
