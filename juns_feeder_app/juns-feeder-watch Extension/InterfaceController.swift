//
//  InterfaceController.swift
//  juns-feeder-watch Extension
//
//  Created by jun lee on 10/17/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import WatchKit
import Foundation

var article: WKArticle?
class InterfaceController: WKInterfaceController {
    
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var mainImage: WKInterfaceImage!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        getArticle()
        
    }
    
    func getArticle(){
        article = WKArticle(title: "Watch", image: #imageLiteral(resourceName: "kokomato"))
        article?.title = "Hello"
        
        titleLabel.setText(article?.title)
        mainImage.setImage(article?.image)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
