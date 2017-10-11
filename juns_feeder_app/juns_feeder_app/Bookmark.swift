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
//
//    required init(coder decoder: NSCoder) {
//        self.title = decoder.decodeObject(forKey: "title") as? String ?? ""
//        self.author = decoder.decodeObject(forKey: "author") as? String ?? ""
//        self.date = decoder.decodeObject(forKey: "date") as? String ?? ""
//        self.summary = decoder.decodeObject(forKey: "summary") as? String ?? ""
//        self.url = decoder.decodeObject(forKey: "url") as? String ?? ""
//        self.imageURL = decoder.decodeObject(forKey: "imageURL") as? String ?? ""
//        self.headline = decoder.decodeObject(forKey: "headline") as? String ?? ""
//    }
//
//    func encode(with coder: NSCoder) {
//        coder.encode(title, forKey: "title")
//        coder.encode(author, forKey: "author")
//        coder.encode(date, forKey: "date")
//        coder.encode(summary, forKey: "summary")
//        coder.encode(url, forKey: "url")
//        coder.encode(imageURL, forKey: "imageURL")
//        coder.encode(headline, forKey: "headline")
//    }
}
