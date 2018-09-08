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
    //var dataController: DataController!
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
    private func displayVideosFromChannel(_ channelID: String){
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        YouTubeClient.sharedInstance().getVideosFromChannel(channelID){(results, error) in
            guard error == nil else {
                self.showAlert()
                performUIUpdatesOnMain {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            
            guard let results = results else {
                return
            }
            self.channel.videosForChannel = results

            
            //print("------------------VIdeoArray is: \(self.videos)")
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
        
        if let imageURLString = videos[(indexPath as NSIndexPath).row].videoThumbnailDefaultURL  {
            let imageURL = URL(string: imageURLString)
            cell?.videoImage?.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder"))
            
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
