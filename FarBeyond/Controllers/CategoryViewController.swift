//
//  CategoryViewController.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 3/28/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import Foundation
import UIKit

class CategoryViewController: UIViewController, UITableViewDelegate{
    
    // MARK: - Properties
    let categoryTableViewDelegate = CategoryViewControllerDelegate()
    
    // MARK: - Outlets
    @IBOutlet weak var categoryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryTableView.delegate = self.categoryTableViewDelegate
        categoryTableView.dataSource = self.categoryTableViewDelegate
        
        categoryTableView.reloadData()
    }
}
