//
//  TestViewController.swift
//  Project7
//
//  Created by MacPro on 12/20/16.
//  Copyright © 2016 Paul Hudson. All rights reserved.
//

import UIKit
import SDWebImage
import CoreData

class TestViewController: UIViewController, UICollectionViewDataSource, UINavigationControllerDelegate , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var collectionView: UICollectionView!
    var petitions = [[String: String]]()
    var pageNumber = 0
    var refresher :UIRefreshControl!
    
    func LoadingView(){
        
        
        
        DispatchQueue.global().async {
            var urlString: NSURL?
            
            print(self.navigationItem.title)
            
            if self.navigationController?.tabBarItem.tag == 0 { // self.navigationItem.title == "Most Recent" { //self.tabBarItem.tag == 0 {
                urlString = NSURL(string:"http://api.themoviedb.org/3/movie/popular?api_key=7087d1f9cfd0b1f535b1476c47d371c4&page=\(self.pageNumber)")!
                self.title = "Pop Movies"
            } else if self.navigationController?.tabBarItem.tag == 1 {
                urlString = NSURL(string:"http://api.themoviedb.org/3/movie/top_rated?api_key=7087d1f9cfd0b1f535b1476c47d371c4&page=\(self.pageNumber)")!
                self.title = "Most Rated"
            }else {
                self.title = "Favorites"
                self.Favorites()
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }

            if self.navigationController?.tabBarItem.tag != 2{
                if let url = urlString {
                    if let data = try? Data(contentsOf: url as URL) {
                        let json = JSON(data: data)
                        self.parse(json: json)
                        print(self.petitions)
                    }
                }
                print(self.petitions.count)
                
                DispatchQueue.main.async {
                    //self.reload()
                    self.collectionView.reloadData()
                    self.refresher.endRefreshing()
                }
            }
         
        }
        
    }
    /*
    func reload() {
        for i in 0...100000 {
            print("\(i)")
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.refresher.endRefreshing()
        }
    }*/
    
    func retriveAllData() -> [NSManagedObject]{
        
        
        var movies : [NSManagedObject] = []
        
        let appDel : DataController = DataController.instance // UIApplication.shared.delegate as! DataController
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let requset2 = NSFetchRequest<NSManagedObject>(entityName: "Movie")
        requset2.returnsObjectsAsFaults = false
        
        do{
            movies  = try context.fetch(requset2) as [NSManagedObject]
            print("movie count =\(movies.count)")
            if movies.count > 0 {
                for i in movies  {
                    print(i)
                }
            }
            
        }catch{}
        
        return movies
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                //self.navigationController.
        navigationController?.navigationBar.barTintColor = UIColor.darkGray
        //navigationController?.tabBarItem.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.navigationController?.tabBarItem.tag != 2{
            refresher = UIRefreshControl()
            refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
            refresher.addTarget(self, action: #selector(TestViewController.refresh), for: UIControlEvents.valueChanged)
            refresher.backgroundColor = UIColor.white
            refresher.tintColor = UIColor.black
            collectionView.refreshControl = refresher
        }
        refresh()
    }
    
    func RefreshController(message: String,view: UIScrollView) -> UIRefreshControl {
        let refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: message)
        refresher.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        collectionView.refreshControl = refresher
        return refresher
    }
    
    func refresh(){
        pageNumber = 0
        petitions.removeAll()
        self.collectionView.reloadData()
        collectionView.dataSource = self
        collectionView.delegate = self
        if self.navigationController?.tabBarItem.tag == 2{
            LoadingView()
        }
    }
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView.contentSize.height - scrollView.contentOffset.y <= scrollView.frame.height {
//        }
//    }
    
    
    func Favorites() {
        
        let movies : [NSManagedObject] = self.retriveAllData()
        
        for movie in movies {
            
            let MovieID = String(movie.value(forKey: "id") as? Int ?? -1)
            let MovieName = movie.value(forKey: "title")
            let overview = movie.value(forKey: "overview")
            let poster = movie.value(forKey: "posterPath")
            let relesed = movie.value(forKey: "releaseDate")
            let backdrop = movie.value(forKey: "backdropPath")
            let ratingDouble = movie.value(forKey: "voteAverage")
            let rating = String(format: "%.01f", ratingDouble as! Double )
            
            let obj = ["title": MovieName, "overview": overview, "poster_path": poster,"release_date": relesed,"backdrop_path": backdrop ,"vote_average": rating, "id": MovieID]
            petitions.append(obj as! [String : String])
        }
    }
    
    func parse(json: JSON) {
        for result in json["results"].arrayValue {
            
            let MovieID = result["id"].stringValue
            let MovieName = result["title"].stringValue
            let overview = result["overview"].stringValue
            let poster = result["poster_path"].stringValue
            let relesed = result["release_date"].stringValue
            let backdrop = result["backdrop_path"].stringValue
            let ratingDouble = result["vote_average"].doubleValue
            let rating = String(format: "%.01f", ratingDouble)
            
            let obj = ["title": MovieName, "overview": overview, "poster_path": poster,"release_date": relesed,"backdrop_path": backdrop ,"vote_average": rating, "id": MovieID]
            petitions.append(obj)
        }
    }
    
    override func viewDidLayoutSubviews() {
//        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize =
        //self.navigationController?.setNavigationBarHidden(true, animated: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.navigationController?.tabBarItem.tag != 2{
            return petitions.count + 1
        }else{
            return petitions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (indexPath.row == collectionView.numberOfItems(inSection: 0) - 1) && self.navigationController?.tabBarItem.tag != 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "indicatorCell", for: indexPath)
            if !(refresher?.isRefreshing ?? true) {
                (cell.viewWithTag(1) as? UIActivityIndicatorView)?.startAnimating()
                (cell.viewWithTag(1) as? UIActivityIndicatorView)?.tintColor = UIColor.white
            } else {
                (cell.viewWithTag(1) as? UIActivityIndicatorView)?.isHidden = true
            }
            pageNumber += 1
            LoadingView()
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCell
            //cell.textLabel?.text = petition["title"]
            let baseURL = "http://image.tmdb.org/t/p/w185"
            let imageURL = baseURL + petitions[indexPath.row]["poster_path"]!
            let url  = URL(string:imageURL)
            cell.MovieImage.sd_setImage(with: url)
            cell.petition = petitions[indexPath.row]
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (indexPath.row == collectionView.numberOfItems(inSection: 0) - 1) && self.navigationController?.tabBarItem.tag != 2{
            return CGSize(width: self.view.frame.width, height: 50)
        } else {
            return CGSize(width: self.view.frame.width / 2, height: self.view.frame.height / 2)
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Detail") as! DetailViewController
//        vc.backdrop = petitions[indexPath.row]
//        vc.rating = petitions[indexPath.row]
//        vc.overview = petitions[indexPath.row]
//        vc.released = petitions[indexPath.row]
//        vc.poster = petitions[indexPath.row]
//        /*var webView: WKWebView!
//         var titles: [String: String]!
//         var backdrop: [UIImage: UIImage]!
//         var rating: [Float: Float]!
//         var overview: [String: String]!
//         var released: [String: String]!
//
//        navigationController?.pushViewController(vc, animated: true)
//        self.present(vc, animated: true, completion: nil)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMovieDetail" {
            if let destination = (segue.destination as? DetailViewController), let petition = (sender as? MovieCell)?.petition {
                destination.backdrop = petition
                destination.rating = petition
                destination.overview = petition
                destination.released = petition
                destination.poster = petition
                destination.MovieName = petition
                destination.MovieID = petition
                
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 200 {
            UIView.animate(withDuration: 1, animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
            })
        } else if scrollView.isDragging{
            UIView.animate(withDuration: 1, animations: {
                self.navigationController?.setNavigationBarHidden(true, animated: false)
            })
        }
    }
    
    
}
