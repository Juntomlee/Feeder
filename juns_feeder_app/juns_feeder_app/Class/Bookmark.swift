//
//  Bookmark.swift
//  juns_feeder_app
//
//  Created by jun lee on 10/8/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import Foundation

class Bookmark: News{
    var title: String
    var author: String
    var date: String
    var summary: String
    var url: String
    
    init(imageURL: String, headline: String, title: String, author: String, date: String, summary: String, url: String ) {
        self.title = title
        self.author = author
        self.date = date
        self.summary = summary
        self.url = url
        super.init(imageURL: imageURL, headline: headline)
    }
}
