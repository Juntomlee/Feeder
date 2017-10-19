//
//  ListTableViewController.swift
//  juns_feeder_app
//
//  Created by jun lee on 10/7/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {

    //MARK: Variables
    var news: News?
    var article = [Article]()
    var categoryList = [News]()
    var articleTitle: String = "Loading..."
    var articleAuthor: String = ""
    var articleDate: String = ""
    var articleCategory: String = ""
    var articleSummary: String = ""
    var articleUrl: String = ""
    var imageData = [UIImage]()
    var recent =  Int()
    var section = String()
    
    //API call var
    var headline = [String]()
    var categoryImage :String = ""
    
    //MARK: Actions
    @IBAction func refreshControl(_ sender: Any) {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    @IBAction func sortButton(_ sender: UIBarButtonItem) {
        sortAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = news?.headline
        updateCategory()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        tableView.reloadData(); // notify the table view the data has changed
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
    
    // API Call
    func updateCategory() {
    // Setup the URL Request...
        //loadingAlert()

        let urlString = "https://api.nytimes.com/svc/mostpopular/v2/mostshared/\(news?.headline ?? "0")/\(recent).json?api-key=f24b2b78b2dc4aed8e0c8dde250581ac"
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
                        if let results = dictionary["results"] as? [[String:AnyObject]]{
                            //print(results[1])
                            for result in results{
                                //Take title of articles
                                self.articleTitle = result["title"] as! String
                                self.articleAuthor = result["byline"] as! String
                                self.articleDate = result["published_date"] as! String
                                self.articleCategory = result["section"] as! String
                                self.articleUrl = result["url"] as! String
                                self.articleSummary = result["abstract"] as! String
                                
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
                                            //self.imageData.append(UIImage(data: savedImage!)!)
                                            let myNews = Article(imageURL: self.categoryImage, headline: self.articleCategory, title: self.articleTitle, author: self.articleAuthor, date: self.articleDate, summary: self.articleSummary, url: self.articleUrl, mark: true, imageFile: UIImage(data: savedImage!))
                                        self.article.append(myNews)
                                        print("test")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    self.dismissAlert()

                    DispatchQueue.main.async{
                        self.tableView?.reloadData()
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
    
    func loadingAlert(){
        let alert = UIAlertController(title: nil, message: "Loading \(section)...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
    }
    
    func dismissAlert() {
        dismiss(animated: true, completion: nil)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return article.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListTableViewCell

        // Configure the cell...
        print("TableCell")
        
        //-----Need to fetch image data during parsing-----//
        let myCategoryNews = article[indexPath.row]
        cell.thumbnailImage.image = myCategoryNews.imageFile
        cell.titleLabel.text = myCategoryNews.title
        cell.dateLabel.text = myCategoryNews.date
        cell.authorLabel.text = myCategoryNews.author

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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

            guard let selectedArticleCell = sender as? ListTableViewCell else {
                fatalError()
            }

            guard let indexPath = tableView?.indexPath(for: selectedArticleCell) else {
                fatalError()
            }

            print(indexPath.row)
            let selectedArticle = article[indexPath.row]
            detailViewController.detailArticle = selectedArticle
            let fullArticle = article
            detailViewController.detailArticleList = fullArticle
        }
    }

}
