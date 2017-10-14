//
//  FeederCollectionViewController.swift
//  juns_feeder_app
//
//  Created by jun lee on 10/6/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import UIKit

private let reuseIdentifier = "myCell"

class FeederCollectionViewController: UICollectionViewController {

    var menuVC: MenuViewController!
    var category = ["Arts", "Automobiles", "Books", "Education", "Fashion&Style", "Blogs",
                    "Food", "Health", "JobMarket", "Magazine", "Movies", "Multimedia", "Open",
                    "Opinion", "RealEstate", "Science", "Sports", "Style", "Technology", "Theater",
                    "Travel", "U.S.", "World", "YourMoney", "BusinessDay", "NYTNow", "Open",
                    "RealEstate", "TMagazine"] //29 categories

    var newss = [News]()
    var imageData = [UIImage]()
    var recent = 7
    
    // MARK: Menu Action
    
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
    

    func showMenu() {
        UIView.animate(withDuration: 0.3) {() -> Void in
            self.menuVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.addChildViewController(self.menuVC)
            self.view.addSubview(self.menuVC.view)
            AppDelegate.menuBool = false
        }
    }
    
    func hideMenu() {
        UIView.animate(withDuration: 0.3) {() -> Void in
            self.menuVC.view.removeFromSuperview()
            AppDelegate.menuBool = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        menuVC = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        updateCategory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var categoryImageList = [String]()
    var headline = [String]()
    var categoryImage :String = ""
    var myNews = News(imageURL: "", headline: "Loading...")
    
    func loadingAlert(){
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        loadingIndicator.hidesWhenStopped = true

        present(alert, animated: true, completion: nil)
    }
    
    func dismissAlert() {
        dismiss(animated: true, completion: nil)
    }
    
    func connectionAlert() {
        let alertController = UIAlertController(title: "News not available", message: "Check your internet connection", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }

    func updateCategory() {
        
        // Setup the URL Request...
        self.loadingAlert()

        for i in 0..<category.count{
            let urlString = "https://api.nytimes.com/svc/mostpopular/v2/mostshared/\(category[i])/\(recent).json?api-key=f24b2b78b2dc4aed8e0c8dde250581ac"
            let requestUrl = URL(string:urlString)
            let request = URLRequest(url:requestUrl!)
            // Setup the URL Session...
            
            let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) in

                guard error == nil else{
                    //DispatchQueue.main.async() {
                        self.connectionAlert()
                    //}
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
                
                // Process the Response...
                if error == nil,let usableData = data {
                    print("JSON Received...File Size: \(usableData) \n")
                    //ready for JSONSerialization
                    do {
                        let object = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments)
                        //print(object)
                        
                        if let dictionary = object as? [String:AnyObject]{
                            //print(dictionary)
                            if let results = dictionary["results"] as? [[String:AnyObject]]{
                                //print(results[1])
                                for result in results{
                                    //print(result)
                                    if let medias = result["media"] as? [[String:AnyObject]]{
                                        for media in medias{
                                            //print(media["media-metadata"])
                                            if let metadatas = media["media-metadata"] as? [[String:AnyObject]]{
                                                //print(url)
                                                for metadata in metadatas{
                                                    self.categoryImage = metadata["url"] as! String
                                                }
                                                let url = URL(string: self.categoryImage)
                                                let savedImage = try? Data(contentsOf: url!)
                                                self.imageData.append(UIImage(data: savedImage!)!)
                                                self.categoryImageList = [self.categoryImage]
                                                self.myNews = News(imageURL: self.categoryImage, headline: self.category[i])
                                                self.newss.append(self.myNews)
                                                print("test")
                                                break
                                            }
                                            break
                                        }
                                        break
                                    }
                                }
                            }
                        }
                        
                        DispatchQueue.main.async{
                            self.collectionView?.reloadData()
                        }
                        self.dismissAlert()
                    } catch {
                        //    // Handle Error
                        print("Error deserializing JSON:")
                    }
                    // Else take care of Networking error
                } else {
                    // Handle Error and Alert User
                    print("Networking Error: \(String(describing: error) )")
                }
            }
        // Execute the URL Task
        task.resume()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return newss.count
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeederCollectionViewCell
        let news = newss[indexPath.row]
//        let url = URL(string: news.imageURL)
//        let data = try? Data(contentsOf: url!)
//        let image: UIImage = UIImage(data: data!)!
        print(indexPath.row)
        cell.myImage.image = imageData[indexPath.row]
        cell.myLabel.text = news.headline
        navigationItem.title = "New York Times"
        // Configure the cell

        return cell
    }

//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "listView", sender: indexPath)
//
//    }
    
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
            
            print(indexPath.row)
            let selectedCategory = newss[indexPath.row]
            ListTableViewController.news = selectedCategory
            ListTableViewController.recent = recent
        }
    }
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
