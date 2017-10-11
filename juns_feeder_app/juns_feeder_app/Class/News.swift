//
//  News.swift
//  juns_feeder_app
//
//  Created by jun lee on 10/7/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import Foundation

class News {
    var imageURL: String
    var headline: String
    
    init(imageURL: String, headline: String) {
        self.imageURL = imageURL
        self.headline = headline
    }
}
