//
//  MenuViewController.swift
//  juns_feeder_app
//
//  Created by jun lee on 10/10/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties
    let titleArray = ["Home", "Bookmark", "Contact Jun"]
    
    // MARK: Outlets
    @IBOutlet weak var menuTableView: UITableView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        menuTableView.delegate = self
        menuTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuTableViewCell
        cell.titleLabel.text = titleArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0: self.performSegue(withIdentifier: "viewMain", sender: self);
        break;
        case 1: self.performSegue(withIdentifier: "viewBookmark", sender: self);
        break;
        default:
            break
        }
    }
}
