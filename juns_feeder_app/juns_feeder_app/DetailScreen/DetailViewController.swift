//
//  DetailViewController.swift
//  juns_feeder_app
//
//  Created by jun lee on 10/8/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import UIKit
import FacebookShare
import FacebookCore

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var detailArticle: Article?
    var bookmark = [Article]() //Temporary array to add item to Bookmark
    var detailArticleList = [Article]()
    var currentLocation: Int = 0
    
    @IBAction func urlLink(_ sender: UIButton) {
        if let myUrl = URL(string: (detailArticle?.url)!){
            UIApplication.shared.open(myUrl, options: [:], completionHandler: nil)
        }
    }
    @IBAction func shareButton(_ sender: Any) {
        //Share on Facebook
        let myContent = LinkShareContent(url: URL(string: (detailArticle?.url)!)!, title: detailArticle?.title, description: detailArticle?.summary, imageURL: URL(string: (detailArticle?.imageURL)!))

        let shareDialog = ShareDialog(content: myContent)
        shareDialog.mode = .native
        shareDialog.failsOnInvalidData = true
        shareDialog.completion = { result in
        }
        
        do{
            try shareDialog.show()
        } catch {
            fatalError()
        }
    }
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        addAlert()
    }
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeToUpdate))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeToUpdate))
        swipeRight.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func saveImage(_ sender: UILongPressGestureRecognizer) {
        let alertController = UIAlertController(title: "Save photo?", message: "", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
            let url = URL(string: (self.detailArticle?.imageURL)!)
            let data = try? Data(contentsOf: url!)
            let myImage: UIImage = UIImage(data: data!)!
            let imageData = UIImagePNGRepresentation(myImage)
            let compressedImage = UIImage(data: imageData!)
            UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    //MARK: Find current location of selected article
    func findLocation() -> Int {
        for i in 0..<detailArticleList.count{
            if detailArticleList[i].title == detailArticle?.title{
                currentLocation = i
                break
            }
        }
        return currentLocation
    }
    
    func moveToNext() {
        var myLocation = findLocation()
        if myLocation == detailArticleList.count - 1{
        } else {
            myLocation += 1
        }
        detailArticle = detailArticleList[myLocation]
    }
    
    func moveToPrev() {
        var myLocation = findLocation()
        if myLocation == 0{
        } else {
            myLocation -= 1
        }
        detailArticle = detailArticleList[myLocation]
    }
    
    @objc func swipeToUpdate(gesture: UIGestureRecognizer){
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            switch swipeGesture.direction{
            case UISwipeGestureRecognizerDirection.right:
                moveToPrev()
                myTableView.reloadData()
                print("Swipe to right")

            case UISwipeGestureRecognizerDirection.left:
                moveToNext()
                myTableView.reloadData()
                print("Swipe to left")
            default:
                print("Gesture not recognized")
            }
        }
    }
    
    //MARK: Adding Book Mark Alert
    func addAlert() {
        let alertController = UIAlertController(title: "Add to Bookmark List?", message: "", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
            // do something like...
            // add item to Bookmark class and use user default to save
            self.load()
            self.detailArticle?.mark = true
            self.bookmark.append(self.detailArticle!)
            //print(self.detailArticle?.mark)
            self.save()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Mark: Save data
    func save() {
        let savedData = NSKeyedArchiver.archivedData(withRootObject: bookmark)
        let defaults = UserDefaults.standard
        defaults.set(savedData, forKey: "bookmark")
    }
    
    // MARK: Load data
    func load(){
        let defaults = UserDefaults.standard
        if let loadData = defaults.object(forKey: "bookmark") as? Data {
            bookmark = NSKeyedUnarchiver.unarchiveObject(with: loadData) as! [Article]
        }
    }
    
    //MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myArticle = detailArticle

        if indexPath.row % 2 == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! DetailImageTableViewCell
            
            let url = URL(string: (myArticle?.imageURL)!)
            let data = try? Data(contentsOf: url!)
            let image: UIImage = UIImage(data: data!)!

            cell.mainImage.image = image
            cell.titleLabel.text = myArticle?.title
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "summaryCell", for: indexPath) as! DetailSummaryTableViewCell
            
            cell.authorLabel.text = myArticle?.author
            cell.summaryLabel.text = myArticle?.summary
            cell.dateLabel.text = myArticle?.date
            return cell
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


