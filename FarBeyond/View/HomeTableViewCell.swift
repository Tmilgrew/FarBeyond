//
//  HomeTableViewCell.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 5/20/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var videoCollectionView: UICollectionView!
    
    
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        
        videoCollectionView.delegate = dataSourceDelegate
        videoCollectionView.dataSource = dataSourceDelegate
        videoCollectionView.tag = row
        videoCollectionView.reloadData()
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

    
    
}
