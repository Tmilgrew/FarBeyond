//
//  VideoTableViewCell.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 5/19/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoDescription: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}
