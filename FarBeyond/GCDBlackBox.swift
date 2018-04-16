//
//  GCDBlackBox.swift
//  On The Map
//
//  Created by Thomas Milgrew on 11/15/17.
//  Copyright © 2017 Thomas Milgrew. All rights reserved.
//

import Foundation


func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
