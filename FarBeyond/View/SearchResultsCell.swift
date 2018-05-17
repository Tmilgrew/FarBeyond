//
//  SearchResultsCell.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 5/14/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import UIKit

class SearchResultsCell: UITableViewCell {

    @IBOutlet weak var channelImage: UIImageView!
    @IBOutlet weak var channelTitle: UILabel!
    @IBOutlet weak var channelDescription: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
