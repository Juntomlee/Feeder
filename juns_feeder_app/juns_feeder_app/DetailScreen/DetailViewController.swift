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

    // MARK: Properties
    var detailArticle: Article?
    var bookmark = [Article]()
    var detailArticleList = [Article]()
    
    // MARK: Outlets
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var myTableView: UITableView!

    // MARK: Actions
    @IBAction func urlLink(_ sender: UIButton) {
        if let myUrl = URL(string: (detailArticle?.url)!){
            UIApplication.shared.open(myUrl, options: [:], completionHandler: nil)
        }
    }
    @IBAction func shareButton(_ sender: Any) {
        shareAlert()
    }
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        addAlert()
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeToUpdate))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeToUpdate))
        swipeRight.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)

        DispatchQueue.main.async {
            self.checkBookmark()
        }
    }
    
    func loadNext() {
        if getCurrentArticleIndex() == detailArticleList.count-1{
            let alertController = UIAlertController(title: "End of the list", message: "", preferredStyle: .actionSheet)
            
            self.present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func loadPrev() {
        if getCurrentArticleIndex() == 0{
            let alertController = UIAlertController(title: "Beginning of the list", message: "", preferredStyle: .actionSheet)
            
            self.present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
//
//    func dismissAlert() {
//        // Dismiss the alert from here
//        dismiss(animated: true, completion: nil)
//    }
//
    func checkBookmark() {
        if checkDuplicate() == false {
            self.navigationItem.rightBarButtonItem?.isEnabled = checkDuplicate()
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = (self.detailArticle?.mark)!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Mark: Alert to ask if user wants to share of Facebook
    func shareAlert(){
        let alertController = UIAlertController(title: "Share on Facebook?", message: "", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Share", style: .default, handler:{action in self.shareOnFacebook()}))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))

        self.present(alertController, animated: true, completion: nil)
    }
    
    func shareOnFacebook() {
        let myContent = LinkShareContent(url: URL(string: (detailArticle?.url)!)!, title: detailArticle?.title, description: detailArticle?.summary, imageURL: URL(string: (detailArticle?.imageURL)!))
        
        let shareDialog = ShareDialog(content: myContent)
        shareDialog.mode = .native
        shareDialog.failsOnInvalidData = true
        shareDialog.completion = { result in }
        
        do{
            try shareDialog.show()
        } catch {
            fatalError()
        }
    }
    
    //Mark: Check if article is in the bookmark
    func checkDuplicate() -> Bool {
        guard let bookmark = load() else {
            fatalError()
        }
        var isDuplicate = true
        for i in 0..<bookmark.count{
            if bookmark[i].title == detailArticle?.title{
                isDuplicate = false
            }
        }
        return isDuplicate
    }
    
    //MARK: Find current location of selected article
    func getCurrentArticleIndex() -> Int {
        var currentArticleIndex = 0
        for i in 0..<detailArticleList.count{
            if detailArticleList[i].title == detailArticle?.title{
                currentArticleIndex = i
                break
            }
        }
        return currentArticleIndex
    }
    
    func moveToNext() {
        var currentArticleIndex = getCurrentArticleIndex()
        if currentArticleIndex == detailArticleList.count - 1{
        } else {
            currentArticleIndex += 1
        }
        detailArticle = detailArticleList[currentArticleIndex]
    }
    
    func moveToPrev() {
        var currentArticleIndex = getCurrentArticleIndex()
        if currentArticleIndex == 0{
        } else {
            currentArticleIndex -= 1
        }
        detailArticle = detailArticleList[currentArticleIndex]
    }
    
    @objc func swipeToUpdate(gesture: UIGestureRecognizer){
        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
            switch swipeGesture.direction{
            case UISwipeGestureRecognizerDirection.right:
                moveToPrev()
                myTableView.reloadData()
                checkBookmark()
                loadPrev()
            case UISwipeGestureRecognizerDirection.left:
                moveToNext()
                myTableView.reloadData()
                checkBookmark()
                loadNext()
            default:
                print("Gesture not recognized")
            }
        }
    }
    
    //MARK: Adding Book Mark Alert
    func addAlert() {
        
        let alertController = UIAlertController(title: "Add to Bookmark List?", message: "", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
            self.bookmark = self.load()!
            self.detailArticle?.mark = false
            self.bookmark.append(self.detailArticle!)
            self.save()
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem?.isEnabled = (self.detailArticle?.mark)!
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Save data
    func save() {
        NSKeyedArchiver.archiveRootObject(bookmark, toFile: Article.ArchiveURL.path)
                let savedData = NSKeyedArchiver.archivedData(withRootObject: bookmark)
                let defaults = UserDefaults.standard
                defaults.set(savedData, forKey: "bookmark")
    }
    
    // MARK: Load data
    func load() -> [Article]?{
        guard let loadingData = NSKeyedUnarchiver.unarchiveObject(withFile: Article.ArchiveURL.path) as? [Article] else {
            fatalError()
        }
        return loadingData
    }
    
    // MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let myArticle = detailArticle else {
            fatalError()
        }

        if indexPath.row % 2 == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! DetailImageTableViewCell
            
            let url = URL(string: myArticle.imageURL)
            let data = try? Data(contentsOf: url!)
            let image: UIImage = UIImage(data: data!)!

            cell.mainImage.image = image
            cell.titleLabel.text = myArticle.title
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "summaryCell", for: indexPath) as! DetailSummaryTableViewCell
            
            cell.authorLabel.text = myArticle.author
            cell.summaryLabel.text = myArticle.summary
            cell.dateLabel.text = myArticle.date
            return cell
        }
    }
}
