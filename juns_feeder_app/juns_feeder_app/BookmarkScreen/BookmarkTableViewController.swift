//
//  BookmarkTableViewController.swift
//  juns_feeder_app
//
//  Created by jun lee on 10/8/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import UIKit
import UserNotifications

class BookmarkTableViewController: UITableViewController {
    
    var bookmark = [Article]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Bookmark"
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Working")
            } else {
                print("Not working")
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        load()
        //print(bookmark)
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        let myNewButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(notifyAlert))
        self.navigationItem.rightBarButtonItem = myNewButton
    }
    
    @objc func notifyAlert(){
        let alertController = UIAlertController(title: "Reminder", message: "Will notify you in 5sec", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes!", style: .default, handler: { (_) in
            self.notifyUser()
            }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alertController, animated: true, completion: nil)
    }
    
    func notifyUser(){
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Articles to Read"
        content.body = "You have \(bookmark.count) items bookmarked"
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default()
        
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Save data
    func save() {
        NSKeyedArchiver.archiveRootObject(bookmark, toFile: Article.ArchiveURL.path)
//        let savedData = NSKeyedArchiver.archivedData(withRootObject: bookmark)
//        let defaults = UserDefaults.standard
//        defaults.set(savedData, forKey: "bookmark")
    }
    
    // MARK: Load data
    func load() -> [Article]?{
        bookmark = (NSKeyedUnarchiver.unarchiveObject(withFile: Article.ArchiveURL.path) as? [Article])!
        return bookmark
//        let defaults = UserDefaults.standard
//        if let loadData = defaults.object(forKey: "bookmark") as? Data {
//            bookmark = NSKeyedUnarchiver.unarchiveObject(with: loadData) as! [Article]
//        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return bookmark.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let myBookmark = bookmark[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkCell", for: indexPath) as! BookmarkTableViewCell

        // Configure the cell...
        let url = URL(string: (myBookmark.imageURL))
        let data = try? Data(contentsOf: url!)
        let image: UIImage = UIImage(data: data!)!
        cell.thumbnailImage.image = image
        cell.titleLabel.text = myBookmark.title

        return cell
    }
    
    // MARK: Delete cell
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            //Delete row and update
            tableView.beginUpdates()
            bookmark.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            tableView.reloadData()
            save()
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "detailView"{
            guard let detailViewController = segue.destination as? DetailViewController else {
                fatalError()
            }
            
            guard let selectedArticleCell = sender as? BookmarkTableViewCell else {
                fatalError()
            }
            
            guard let indexPath = tableView?.indexPath(for: selectedArticleCell) else {
                fatalError()
            }
            
            print(indexPath.row)
            let selectedBookmark = bookmark[indexPath.row]
            detailViewController.detailArticle = selectedBookmark
            let fullArticle = bookmark
            detailViewController.detailArticleList = fullArticle
        }
    }

}
