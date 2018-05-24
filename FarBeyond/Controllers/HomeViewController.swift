//
//  HomeViewController.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 5/15/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import youtube_ios_player_helper

class HomeViewController : UIViewController {
    
    // MARK: Properties
    var dataController : DataController!
    var channels : [Channel]! = []
    var videos : [Video]!
    var lastVideoIdUsed : String = ""
    
    // MARK: Outlets
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var debugLabel: UILabel!
    
    @IBOutlet weak var videoPlayer: YTPlayerView!
    
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableView.delegate = self
        homeTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if lastVideoIdUsed == "" {
            debugLabel.isHidden = false
        } else {
            debugLabel.isHidden = true
            videoPlayer.load(withVideoId: lastVideoIdUsed)
        }
        
        // 1. Make a fetch request and fetch all the channels the user is subscribed to
        let fetchRequest : NSFetchRequest<Channel> = Channel.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key:"channelTitle", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let results = try?dataController.viewContext.fetch(fetchRequest) {
            guard results.count != 0 else {
                return
            }
            channels = results
            
            for channel in channels {
                if (channel.channelToVideo?.count == 0 || channel.channelToVideo?.count==nil) {
                    displayVideosFromChannel(channel.channelID!) {(results, error) in
                        guard error == nil else {
                            self.showAlert()
                            return
                        }

                        for video in results! {
                            
                            let newVideo = Video(context: self.dataController.viewContext)
                            
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
                            newVideo.videoToChannel = channel
                            try? self.dataController.viewContext.save()
                        }
                    }
                }
                }
            }
            homeTableView.reloadData()
        }
    
    
    private func displayVideosFromChannel(_ video: String, completionHndlerForDisplayVideosFromChannel: @escaping (_ results: [AnyObject]?, _ errror: NSError?) -> Void){
        
        YouTubeClient.sharedInstance().getVideosFromChannel(video){(results, error) in
            completionHndlerForDisplayVideosFromChannel(results, error)
        }
    }
    
    
    
    @IBAction func deleteChannel(_ sender: UIButton) {
        let buttonTag = sender.tag
        let thisChannel = channels[buttonTag]
        
        let fetchRequest:NSFetchRequest<Channel> = Channel.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "channelTitle", ascending: true)
        fetchRequest.sortDescriptors=[sortDescriptor]
        let predicate = NSPredicate(format: "channelTitle == %@", thisChannel.channelTitle!)
        fetchRequest.predicate = predicate
        
        if let results = try? dataController.viewContext.fetch(fetchRequest) {
            dataController.viewContext.delete(results[0])
            try? dataController.viewContext.save()
            
            performUIUpdatesOnMain {
                self.channels.remove(at: buttonTag)
                self.homeTableView.reloadData()
            }
        }
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "Network Error", message: "You are not connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
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
    
extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let reuseId = "header"
        let header = tableView.dequeueReusableCell(withIdentifier: reuseId) as? SectionHeaderView
        
        let channel = channels[section]
        header?.channelTitle?.text = channel.channelTitle
        
            if channel.channelThumbnailData == nil {
                    //            cell?.imageView?.image = UIImage(named: "placeholder")
                    //            cell.activityIndicator.isHidden = false
                    //            cell.activityIndicator.startAnimating()
        
                
                
                    DispatchQueue.main.async(){
                        guard let image = try? UIImage(data: Data(contentsOf: URL(string: (channel.channelThumbnailURL)!)!)) else {
                            self.showAlert()
                            return
                        }
                        channel.channelThumbnailData = UIImagePNGRepresentation(image!)
                            try? self.dataController.viewContext.save()
                            //                cell.activityIndicator.isHidden = true
                            //                cell.activityIndicator.stopAnimating()
                            performUIUpdatesOnMain {
                                header?.channelImage?.image = image
                                self.homeTableView.reloadData()
                            }
                    
                }
            } else {
                let image = UIImage(data: (channel.channelThumbnailData)!)
                header?.channelImage?.image = image
        }
        
        header?.unfollowButton?.tag = section
        
        return header

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as? HomeTableViewCell
        cell?.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
        return cell!
    }
}




extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let thisSectionsVideos = channels[section].channelToVideo
        return (thisSectionsVideos?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellReuseId = "videoCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseId, for: indexPath) as? HomeCollectionViewCell
        let channel = channels[collectionView.tag]
        
        let fetchRequest : NSFetchRequest<Video> = Video.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "videoTitle", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "videoToChannel == %@", channel)
        fetchRequest.predicate = predicate
        
        if let results = try? dataController.viewContext.fetch(fetchRequest){
            
            if results.count == 0 {
                print("We had no videossssss")
            }
            videos = results
            let video = videos[(indexPath as NSIndexPath).row]
            cell?.homeVideoTitle.text = video.videoTitle
            cell?.homeVideoDescription.text = video.videoDescription
            
            if video.videoThumbnailDefaultData == nil {
                DispatchQueue.main.async {
                    
                    guard let image = try? UIImage(data: Data(contentsOf: URL(string: (video.videoThumbnailDefaultURL)!)!)) else {
                        self.showAlert()
                        return
                    }
                    
                    
                    video.videoThumbnailDefaultData = UIImagePNGRepresentation(image!)
                
                    performUIUpdatesOnMain {
                        cell?.homeVideoImage?.image = image
                    }
                }
                
            } else {
                let image = UIImage(data: (video.videoThumbnailDefaultData)!)
                cell?.homeVideoImage?.image = image
            }
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let channel = channels[collectionView.tag]
        
        let fetchRequest : NSFetchRequest<Video> = Video.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "videoTitle", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "videoToChannel == %@", channel)
        fetchRequest.predicate = predicate
        
        if let results = try? dataController.viewContext.fetch(fetchRequest){
            
            if results.count == 0 {
                print("We had no videossssss")
            }
            videos = results
            let video = videos[(indexPath as NSIndexPath).row]
        
            if let lastVideoIdUsed = video.videoID {
            videoPlayer.load(withVideoId: lastVideoIdUsed)
            }else {
                print("There is no video id")
            }
        }
    }
}



extension HomeViewController : CoreDataClient {
    func setStack(stack: DataController) {
        self.dataController = stack
    }
}
