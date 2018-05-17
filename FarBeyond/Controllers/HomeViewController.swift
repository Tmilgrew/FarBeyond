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
    var channels : [Channel]!
    
    // MARK: Outlets
    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var videoPlayer: YTPlayerView!
    
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        videoCollectionView.delegate = self
        videoCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1. Make a fetch request and fetch all the channels the user is subscribed to
        let fetchRequest : NSFetchRequest<Channel> = Channel.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key:"channelTitle", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let results = try?dataController.viewContext.fetch(fetchRequest) {
            guard results.count != 0 else {
                
                return
            }
            
            channels = results
            videoCollectionView.reloadData()
        }
        
        
        // 2. if the user isn't subscribed to anything, display message
        // 3. if the user is subscribed, check for updated videos
        // 4. Save the videos in structs
        // 5. Display them in collection view
    }
    
}

extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellReuseId = "videoCell"
        let channel = channels[(indexPath as NSIndexPath).row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseId, for: indexPath) as? HomeCollectionViewCell
        
        cell?.homeVideoTitle.text = channel.channelTitle
        cell?.homeVideoDescription.text = channel.channelDescription
        cell?.homeVideoDescription.numberOfLines = 2
        
        if channel.channelThumbnailData == nil {
            DispatchQueue.main.async {
                let image = try! UIImage(data: Data(contentsOf: URL(string: channel.channelThumbnailURL!)!))
                channel.channelThumbnailData = UIImagePNGRepresentation(image!)
                
                performUIUpdatesOnMain {
                    cell?.homeVideoImage?.image = image
                }
            }
            
        } else {
            let image = UIImage(data: (channel.channelThumbnailData)!)
            cell?.homeVideoImage?.image = image
        }
        
        return cell!
    }
    
    
}


extension HomeViewController : CoreDataClient {
    func setStack(stack: DataController) {
        self.dataController = stack
    }
}
