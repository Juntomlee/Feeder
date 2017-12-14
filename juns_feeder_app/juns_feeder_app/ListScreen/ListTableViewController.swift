//
//  ListTableViewController.swift
//  juns_feeder_app
//
//  Created by jun lee on 10/7/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {

    //MARK: Properties
    var news: News?
    var article = [Article]()
    var categoryList = [News]()
    var imageData = [UIImage]()
    var recentNumberOfDays = Int()
    var section = String()
    var headline = [String]()
    
    //MARK: Actions
    @IBAction func refreshControl(_ sender: Any) {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    @IBAction func sortButton(_ sender: UIBarButtonItem) {
        sortAlert()
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = news?.headline
        if ConnectionCheck.isConnectedToNetwork() {
            updateCategory()
        } else {
            connectionAlert()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Network connection alert
    func connectionAlert(){
        let alertController = UIAlertController(title: "Network not available", message: "Check your internet connection", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Sorting
    func sortList(_ type: String) {
        switch type{
        case "date" :
            article.sort(){$0.date > $1.date}
        case "author" :
            article.sort(){$0.author < $1.author}
        case "title" :
            article.sort(){$0.title < $1.title}
        default:
            print("Does not exist")
        }
        tableView.reloadData()
    }
    
    // Sorting Alert
    func sortAlert() {
        var sortType: String = ""
        let alertController = UIAlertController(title: "Sort by", message: "", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Date", style: .default, handler: { action in
            sortType = "date"
            self.sortList(sortType)
        }))
        alertController.addAction(UIAlertAction(title: "Author", style: .default, handler: { action in
            sortType = "author"
            self.sortList(sortType)
        }))
        alertController.addAction(UIAlertAction(title: "Title", style: .default, handler: { action in
            sortType = "title"
            self.sortList(sortType)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateCategory() {
        
        var articleTitle: String = "Loading..."
        var articleAuthor: String = ""
        var articleDate: String = ""
        var articleCategory: String = ""
        var articleSummary: String = ""
        var articleUrl: String = ""
        var categoryImage = String()
        
        // Setup the URL Request
        let urlString = "https://api.nytimes.com/svc/mostpopular/v2/mostshared/\(news?.headline ?? "0")/\(recentNumberOfDays).json?api-key=f24b2b78b2dc4aed8e0c8dde250581ac"
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
                        if let results = dictionary["results"] as? [[String:AnyObject]]{
                            for result in results{
                                //Take title of articles
                                articleTitle = result["title"] as! String
                                articleAuthor = result["byline"] as! String
                                articleDate = result["published_date"] as! String
                                articleCategory = result["section"] as! String
                                articleUrl = result["url"] as! String
                                articleSummary = result["abstract"] as! String
                                
                                if let medias = result["media"] as? [[String:AnyObject]]{
                                    for media in medias{
                                        if let metadatas = media["media-metadata"] as? [[String:AnyObject]]{
                                            for metadata in metadatas{
                                                categoryImage = metadata["url"] as! String
                                            }
                                            let url = URL(string: categoryImage)
                                            let savedImage = try? Data(contentsOf: url!)
                                            let myNews = Article(imageURL: categoryImage, headline: articleCategory, title: articleTitle, author: articleAuthor, date: articleDate, summary: articleSummary, url: articleUrl, mark: true, imageFile: UIImage(data: savedImage!))
                                        self.article.append(myNews)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async{
                        self.tableView?.reloadData()
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
    
    func loadingAlert(){
        let alert = UIAlertController(title: nil, message: "Loading \(section)...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
    }
//
//    func dismissAlert() {
//        dismiss(animated: true, completion: nil)
//    }
//
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return article.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListTableViewCell

        let myCategoryNews = article[indexPath.row]
        cell.thumbnailImage.image = myCategoryNews.imageFile
        cell.titleLabel.text = myCategoryNews.title
        cell.dateLabel.text = myCategoryNews.date
        cell.authorLabel.text = myCategoryNews.author

        return cell
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "detailView"{
            guard let detailViewController = segue.destination as? DetailViewController else {
                fatalError()
            }
            guard let selectedArticleCell = sender as? ListTableViewCell else {
                fatalError()
            }
            guard let indexPath = tableView?.indexPath(for: selectedArticleCell) else {
                fatalError()
            }

            let selectedArticle = article[indexPath.row]
            detailViewController.detailArticle = selectedArticle
            let fullArticle = article
            detailViewController.detailArticleList = fullArticle
        }
    }
}
