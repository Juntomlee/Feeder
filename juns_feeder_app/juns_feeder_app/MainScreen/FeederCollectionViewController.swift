//
//  FeederCollectionViewController.swift
//  juns_feeder_app
//
//  Created by jun lee on 10/6/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import UIKit

private let reuseIdentifier = "myCell"

class FeederCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: Properties
    var menuViewController: MenuViewController!
    var category = ["Arts", "Automobiles", "Books", "Education", "Fashion&Style", "Blogs",
                    "Food", "Health", "JobMarket", "Magazine", "Movies", "Multimedia", "Open",
                    "Opinion", "RealEstate", "Science", "Sports", "Style", "Technology", "Theater",
                    "Travel", "U.S.", "World", "YourMoney", "BusinessDay", "NYTNow", "Open",
                    "RealEstate", "TMagazine"] //29 categories

    var newss = [News]()
    var imageData = [UIImage]()
    var recentNumberOfDays = 7
    var keyword = String()
    var networkCheck = 0
    
    var categoryImageList = [String]()
    var headline = [String]()
    var categoryImage :String = ""
    var myNews = News(imageURL: "", headline: "Loading News...")
    
    // MARK: Actions
    @IBAction func menuAction(_ sender: Any) {
        if AppDelegate.menuBool{
            showMenu()
        } else {
            hideMenu()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideMenu()
    }
    
    @IBAction func searchButton(_ sender: UIBarButtonItem) {
        searchAlert()
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        connectionCheck()
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.connectionCheck), userInfo: nil, repeats: true)
    }
    
    @objc func connectionCheck() {
        if ConnectionCheck.isConnectedToNetwork() {
            if newss.isEmpty{
                updateCategory()
                networkCheck = 0
            }
        } else {
            if networkCheck == 0{
                connectionAlert()
                networkCheck = 1
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Functions
    func showMenu() {
        UIView.animate(withDuration: 0.3) {() -> Void in
            self.menuViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.addChildViewController(self.menuViewController)
            self.view.addSubview(self.menuViewController.view)
            AppDelegate.menuBool = false
        }
    }
    
    func hideMenu() {
        UIView.animate(withDuration: 0.3) {() -> Void in
            self.menuViewController.view.removeFromSuperview()
            AppDelegate.menuBool = true
        }
    }
    
    func searchAlert() {
        let alert = UIAlertController(title: "Search", message: "", preferredStyle: .alert)
        alert.addTextField { (textField : UITextField) -> Void in
            textField.placeholder = "Enter keyword"
        }
        
        alert.addAction(UIAlertAction(title: "Search", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.keyword = (textField?.text!)!
            self.performSegue(withIdentifier: "searchView", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadingAlert(){
        let alert = UIAlertController(title: nil, message: "Loading NYT...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        loadingIndicator.hidesWhenStopped = true

        present(alert, animated: true, completion: nil)
    }
    
    func connectionAlert(){
        let alertController = UIAlertController(title: "Network not available", message: "Check your internet connection", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func dismissAlert() {
        dismiss(animated: true, completion: nil)
    }

    func updateCategory() {
        self.loadingAlert()
        
        // Setup the URL Request...
        for i in 0..<category.count{
            let urlString = "https://api.nytimes.com/svc/mostpopular/v2/mostshared/\(category[i])/\(recentNumberOfDays).json?api-key=f24b2b78b2dc4aed8e0c8dde250581ac"
            let requestUrl = URL(string:urlString)
            let request = URLRequest(url:requestUrl!)
            // Setup the URL Session...
            
            let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) in

                guard error == nil else{
                    self.connectionAlert()
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else{
                    print("HTTP Response error")
                    self.connectionAlert()
                    return
                }
                
                if httpResponse.statusCode != 200 {
                    print("Data request failed")
                    return
                }
                
                // Process the Response
                if error == nil,let usableData = data {
                    print("JSON Received...File Size: \(usableData) \n")
                    //ready for JSONSerialization
                    do {
                        let object = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments)
                        
                        if let dictionary = object as? [String:AnyObject]{
                            if let results = dictionary["results"] as? [[String:AnyObject]]{
                                for result in results{
                                    if let medias = result["media"] as? [[String:AnyObject]]{
                                        for media in medias{
                                            if let metadatas = media["media-metadata"] as? [[String:AnyObject]]{
                                                for metadata in metadatas{
                                                    self.categoryImage = metadata["url"] as! String
                                                }
                                                let url = URL(string: self.categoryImage)
                                                let savedImage = try? Data(contentsOf: url!)
                                                self.imageData.append(UIImage(data: savedImage!)!)
                                                self.categoryImageList = [self.categoryImage]
                                                self.myNews = News(imageURL: self.categoryImage, headline: self.category[i])
                                                self.newss.append(self.myNews)
                                                break
                                            }
                                            break
                                        }
                                        break
                                    }
                                }
                            }
                        }
                        DispatchQueue.main.sync{
                            self.collectionView?.reloadData()
                        }
                        self.dismissAlert()
                    } catch {
                        print("Error deserializing JSON:")
                    }
                } else {
                    print("Networking Error: \(String(describing: error) )")
                }
            }
        task.resume()
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return newss.count
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeederCollectionViewCell
        let news = newss[indexPath.row]
        cell.myImage.image = imageData[indexPath.row]
        cell.myLabel.text = news.headline
        navigationItem.title = "New York Times"

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width : CGFloat
        let height : CGFloat
        
        if collectionView.frame.width > collectionView.frame.height{
            width = (collectionView.frame.width/3)
            height = width
            return CGSize(width: width, height: height)
        } else {
            if indexPath.item % 10 == 0 || indexPath.item % 10 == 6 {
                // First section
                width = (collectionView.frame.width/3) * 2
                height = width
                return CGSize(width: width, height: height)
            } else if indexPath.item % 10 == 1 || indexPath.item % 10 == 5{
                width = (collectionView.frame.width/3)
                height = width * 2
                return CGSize(width: width, height: height)
            } else {
                // Second section
                width = (collectionView.frame.width/3)
                height = width
                return CGSize(width: width, height: height)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "listView"{
            guard let ListTableViewController = segue.destination as? ListTableViewController else {
                fatalError()
            }
            
            guard let selectedCategoryCell = sender as? FeederCollectionViewCell else {
                fatalError()
            }
            
            guard let indexPath = collectionView?.indexPath(for: selectedCategoryCell) else {
                fatalError()
            }
            
            let selectedCategory = newss[indexPath.row]
            ListTableViewController.news = selectedCategory
            ListTableViewController.recentNumberOfDays = recentNumberOfDays
            ListTableViewController.section = selectedCategory.headline
        } else if segue.identifier == "searchView"{
            guard let SearchViewController = segue.destination as? SearchViewController else {
                fatalError()
            }
            SearchViewController.keyword = keyword
        }
    }
}
