//
//  SearchViewController.swift
//  juns_feeder_app
//
//  Created by jun lee on 10/17/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var searchList = [Article]()
    var searchArticle: Article?
    var articleTitle: String = "Loading..."
    var articleAuthor: String = ""
    var articleDate: String = ""
    var articleCategory: String = ""
    var articleSummary: String = ""
    var articleUrl: String = ""
    var imageURL: String = ""
    var imageData = [UIImage]()
    var categoryImage :String = ""
    var keyword: String?
    var isSearching = false

    @IBOutlet weak var articleSearchBar: UISearchBar!
    
    @IBOutlet weak var searchTableView: UITableView!
    

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
            searchList = []
            keyword = articleSearchBar.text!
            updateCategory()
            searchTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        articleSearchBar.placeholder = keyword
        articleSearchBar.delegate = self
        articleSearchBar.returnKeyType = UIReturnKeyType.done
        updateCategory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateCategory() {
        // Setup the URL Request...
        //loadingAlert()
        
        let urlString = "https://api.nytimes.com/svc/search/v2/articlesearch.json?api-key=f24b2b78b2dc4aed8e0c8dde250581ac&q=\(keyword!)"
        let requestUrl = URL(string:urlString)
        let request = URLRequest(url:requestUrl!)
        
        // Setup the URL Session...
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            // Process the Response...
            if error == nil,let usableData = data {
                print("JSON Received...File Size: \(usableData) \n")
                //ready for JSONSerialization
                do {
                    let object = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments)
                    //print(object)
    
                    if let dictionary = object as? [String:AnyObject]{
                        //print(dictionary)
                        if let response = dictionary["response"] as? [String:AnyObject]{
                            //print(response)
                            if let item  = response as? [String: AnyObject]{
                                //print(item["docs"])
                                if let detail = item["docs"] as? [[String:AnyObject]]{
                                    //print(detail)
                                    for item in detail{
                                        self.articleSummary = item["snippet"] as! String
                                        self.articleCategory = item["type_of_material"] as! String
                                        if let headline = item["headline"] as? [String:AnyObject]{
                                            //print(headline["main"]) //Main Headline
                                            if (headline["main"] as! String) == ""{
                                                self.articleTitle = headline["name"] as! String
                                            } else {
                                                self.articleTitle = headline["main"] as! String
                                            }
                                        }
                                        //print(item["web_url"]) //Web URL
                                        self.articleUrl = item["web_url"] as! String
                                        //print(item["multimedia"]) // add https://static01.nyt.com/ for image
                                        if let imageURL = item["multimedia"] as? [[String:AnyObject]]{
                                            for realImage in imageURL{
                                                if let xlarge = realImage["legacy"] as? [String:AnyObject]{
//                                                    self.imageURL = "https://static01.nyt.com/\((xlarge["xlarge"] ?? "" as AnyObject) as! String)"
                                                    self.imageURL = "https://i.pinimg.com/736x/2e/85/6d/2e856d9f7099b4fb0ec2c7c738aed67a--pink-wallpaper-iphone-cute-iphone-wallpapers-cute.jpg"
                                                    //print(xlarge["xlarge"])
                                                    //print(xlarge["thumbnail"])
                                                }
                                                
                                            }
                                            let url = URL(string: self.imageURL)
                                            let savedImage = try? Data(contentsOf: url!)
                                            self.searchArticle = Article(imageURL: self.imageURL, headline: self.articleCategory, title: self.articleTitle, author: "", date: "", summary: self.articleSummary, url: self.articleUrl, mark: false, imageFile: UIImage(data:savedImage!))
                                            self.searchList.append(self.searchArticle!)
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                    //self.dismissAlert()
                    
                    DispatchQueue.main.async{
                        self.searchTableView?.reloadData()
                    }
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
            
            print(indexPath.row)
            let selectedCategory = searchList[indexPath.row]
            DetailViewController.detailArticle = selectedCategory
        } 
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 

}
