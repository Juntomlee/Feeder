//
//  SearchViewController.swift
//  juns_feeder_app
//
//  Created by jun lee on 10/17/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    // MARK: Properties
    var searchList = [Article]()
    var imageData = [UIImage]()
    var categoryImage :String = ""
    var keyword: String?
    var isSearching = false

    // MARK: Outlets
    @IBOutlet weak var articleSearchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        articleSearchBar.text = keyword
        articleSearchBar.delegate = self
        articleSearchBar.returnKeyType = UIReturnKeyType.done
        if ConnectionCheck.isConnectedToNetwork() {
            updateCategory()
        } else {
            connectionAlert()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        articleSearchBar.text = keyword
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Tableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        
        let currentSearchArticle = searchList[indexPath.row]
        cell.thumbnailImage.image = currentSearchArticle.imageFile
        cell.titleLabel.text = currentSearchArticle.title
        cell.dateLabel.text = currentSearchArticle.date
        cell.authorLabel.text = currentSearchArticle.author
        cell.typeLabel.text = currentSearchArticle.headline
        return cell
    }
    
    // MARK: Searchbar delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        isSearching = false;
        self.articleSearchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if articleSearchBar.text == nil || articleSearchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            searchTableView.reloadData()
        } else {
            isSearching = true
            searchList.removeAll()
            keyword = articleSearchBar.text!
            updateCategory()
            searchTableView.reloadData()
        }
    }
    
    // MARK: Functions
    func connectionAlert(){
        let alertController = UIAlertController(title: "Network not available", message: "Check your internet connection", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateCategory() {
        var searchArticle: Article?
        var articleTitle: String = "Loading..."
        var articleCategory: String = ""
        var articleSummary: String = ""
        var articleUrl: String = ""
        var imageURL: String = ""
        
        // Setup the URL Request
        let tempKeyword: String = (keyword?.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil))!
        let urlString = "https://api.nytimes.com/svc/search/v2/articlesearch.json?api-key=f24b2b78b2dc4aed8e0c8dde250581ac&q=\(tempKeyword)"
        let requestUrl = URL(string:urlString)
        let request = URLRequest(url:requestUrl!)
        
        // Setup the URL Session
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            // Process the Response
            if error == nil,let usableData = data {
                print("JSON Received...File Size: \(usableData) \n")
                //ready for JSONSerialization
                do {
                    let object = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments)
    
                    if let dictionary = object as? [String:AnyObject]{
                        if let item = dictionary["response"] as? [String:AnyObject]{
                            if let detail = item["docs"] as? [[String:AnyObject]]{
                                for item in detail{
                                    articleSummary = item["snippet"] as! String
                                    articleCategory = item["type_of_material"] as! String
                                    if let headline = item["headline"] as? [String:AnyObject]{
                                        if (headline["main"] as! String) == ""{
                                            articleTitle = headline["name"] as! String
                                        } else {
                                            articleTitle = headline["main"] as! String
                                        }
                                    }
                                    articleUrl = item["web_url"] as! String
                                    if let imageURLList = item["multimedia"] as? [[String:AnyObject]]{
                                        for realImage in imageURLList{
                                            if let myUrl = realImage["url"]{
                                                imageURL = "https://static01.nyt.com/" + (myUrl as! String)
                                            }
                                            break
                                        }
                                        if imageURL.isEmpty {
                                            imageURL = "https://i.pinimg.com/736x/2e/85/6d/2e856d9f7099b4fb0ec2c7c738aed67a--pink-wallpaper-iphone-cute-iphone-wallpapers-cute.jpg"
                                        }
                                        
                                        let url = URL(string: imageURL)
                                        let savedImage = try? Data(contentsOf: url!)
                                        searchArticle = Article(imageURL: imageURL, headline: articleCategory, title: articleTitle, author: "", date: "", summary: articleSummary, url: articleUrl, mark: true, imageFile: UIImage(data:savedImage!))
                                        self.searchList.append(searchArticle!)
                                    }
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async{
                        self.searchTableView?.reloadData()
                    }
                } catch {
                    print("Error deserializing JSON:")
                }
            } else {
                print("Networking Error: \(String(describing: error) )")
            }
        }
        task.resume()
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "detailView"{
            guard let DetailViewController = segue.destination as? DetailViewController else {
                fatalError()
            }
            guard let selectedCategoryCell = sender as? SearchTableViewCell else {
                fatalError()
            }
            guard let indexPath = searchTableView?.indexPath(for: selectedCategoryCell) else {
                fatalError()
            }
            let selectedCategory = searchList[indexPath.row]
            DetailViewController.detailArticle = selectedCategory
            
            let selectedCategoryList = searchList
            DetailViewController.detailArticleList = selectedCategoryList
        }
    }
}
