//
//  DetailViewController.swift
//  Project7
//
//  Created by TwoStraws on 15/08/2016.
//  Copyright © 2016 Paul Hudson. All rights reserved.
//

import UIKit
import WebKit
import SDWebImage
import CoreData
import Toast_Swift

class DetailViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate {
    var petitionTrailers = [[String: String]]()
    var petitionReviews = [[String: String]]()
    
	var webView: WKWebView!
    var backdrop: [String: String]!
    var rating: [String: String]!
    var overview: [String: String]!
    var released: [String: String]!
    var poster: [String: String]!
    var MovieName: [String: String]!
    var MovieID: [String: String]!
    var isFavorite = true

    @IBOutlet weak var ReleaseDate: UILabel!
    @IBOutlet weak var BackdropImage: UIImageView!
    @IBOutlet weak var overView: UITextView!
    @IBOutlet weak var MovieRating: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var tableHeight: NSLayoutConstraint!
    
    
    func isFavoritef(){
        
        if let o = overview["overview"] , let t = MovieName["title"] ,let va = rating["vote_average"] ,let rd=released["release_date"],let pp=poster["poster_path"], let bp=poster["backdrop_path"] ,let id = MovieID["id"] {
            
            let appDel : DataController = DataController.instance
            
            let context: NSManagedObjectContext = appDel.managedObjectContext
            
            if checkIfExest() == false{
                //for add
                
                let newMovie = NSEntityDescription.insertNewObject(forEntityName: "Movie", into: context)
                newMovie.setValue(NumberFormatter().number(from: id), forKey: "id")
                newMovie.setValue(NSDecimalNumber(string: va), forKey: "voteAverage")
                newMovie.setValue(o, forKey: "overview")
                newMovie.setValue(t, forKey: "title")
                newMovie.setValue(rd, forKey: "releaseDate")
                newMovie.setValue(pp, forKey: "posterPath")
                newMovie.setValue(bp, forKey: "backdropPath")
                
                do{
                    try context.save()
                }catch{
                    print("There was a problem")
                }
                if isFavorite == false{
                    isFavorite = true
                    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(isFavoritef))

                    //self.view.makeToast("Movie Added succefully", duration: 1.0, position: .init(x: view.frame.width/2, y: view.frame.height - ((self.tabBarController?.tabBar.frame.height)! * 2)) )
                    let baseURL = "http://image.tmdb.org/t/p/w185"
                    let imageURL = baseURL + pp
                    let url  = URL(string:imageURL)
                    //let image : UIImage
                    //image.sd_setImage(with: url!)
                    self.view.makeToast("Movie Added succefully", duration: 1.0, position: .init(x: view.frame.width/2, y: view.frame.height - ((self.tabBarController?.tabBar.frame.height)! * 2)), title: ":D", image:  UIImage(data: try! Data(contentsOf: url!)), style: ToastStyle.init(), completion: nil)
                }
                
            }else{
                //for delete
                let requset = NSFetchRequest<NSManagedObject>(entityName: "Movie")
                let fetchPredicate  = NSPredicate(format: "id == %@", id)
                requset.predicate = fetchPredicate
                requset.returnsObjectsAsFaults = false
                
                do{
                    let movie  = try context.fetch(requset)
                    for i in movie as [NSManagedObject] {
                        print(i)
                        context.delete(i)
                    }
                    try context.save()
                    
                }catch let err {print(err)}
                isFavorite = false
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(isFavoritef))
                self.view.makeToast("Movie Removed succefully", duration: 1.0, position: .init(x: view.frame.width/2, y: view.frame.height - ((self.tabBarController?.tabBar.frame.height)! * 2)) )
            }
            //for retrive data
            let requset2 = NSFetchRequest<NSManagedObject>(entityName: "Movie")
            requset2.returnsObjectsAsFaults = false
            
            do{
                let movies  = try context.fetch(requset2) as [NSManagedObject]
                print("movie count =\(movies.count)")
                if movies.count > 0 {
                    print("********************************************************************************************************************************")
                    for i in movies  {
                        print(i)
                        print(i.value(forKey: "title"))
                    }
                    print("********************************************************************************************************************************")
                }
                
            }catch{}
        }
    }
    
    func checkIfExest() ->Bool{
        let appDel : DataController = DataController.instance // UIApplication.shared.delegate as! DataController
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let requset = NSFetchRequest<NSManagedObject>(entityName: "Movie")
        if let id = MovieID["id"] {
            requset.predicate = NSPredicate(format: "id == %@", id)
        }
        requset.returnsObjectsAsFaults = false
        do{
            let movies  = try context.fetch(requset) as [NSManagedObject]
            
            //print("movie count =\(movies.count)")
            if movies.count > 0 {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(isFavoritef))
                isFavorite = true
            }else{
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(isFavoritef))
                isFavorite = false
            }
            // try context.save()
            
        }catch{}
        return isFavorite
    }
    
	override func loadView() {
        super.loadView()
    }

	override func viewDidLoad() {
		super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
		guard overview != nil else { return }

        
		if let o = overview["overview"] , let t = MovieName["title"] ,let va = rating["vote_average"] ,let rd=released["release_date"],let pp=poster["poster_path"] ,let id = MovieID["id"]{

            let baseURL = "http://image.tmdb.org/t/p/w185"
            let imageURL = baseURL + pp
            let url  = URL(string:imageURL)
            BackdropImage.sd_setImage(with: url!)
            MovieRating.text = va
            ReleaseDate.text = rd
            overView.text = o
            title = t
            
            isFavorite = self.checkIfExest()
            
            
            let trailersUrl: NSURL?
            
            //print("URL is " + "http://api.themoviedb.org/3/movie/\(id)/videos?api_key=7087d1f9cfd0b1f535b1476c47d371c4")
            
            trailersUrl = NSURL(string:"http://api.themoviedb.org/3/movie/\(id)/videos?api_key=7087d1f9cfd0b1f535b1476c47d371c4")!
            
            if let url = trailersUrl {
                if let data = try? Data(contentsOf: url as URL) {
                    let json = JSON(data: data)
                    parseTrailer(json: json)
                }
            }
            
            let ReviewsUrl: NSURL?
            ReviewsUrl = NSURL(string:"http://api.themoviedb.org/3/movie/\(id)/reviews?api_key=7087d1f9cfd0b1f535b1476c47d371c4")!
            
            if let url = ReviewsUrl {
                if let data = try? Data(contentsOf: url as URL) {
                    let json = JSON(data: data)
                    parseReviews(json: json)
                }
            }
		}
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func parseTrailer(json: JSON) {
        for trailer in json["results"].arrayValue {
            let id = trailer["id"].stringValue
            let name = trailer["name"].stringValue
            let key = trailer["key"].stringValue
            
            let obj = ["id": id, "name": name, "key" : key]
            petitionTrailers.append(obj)
            print(trailer)
        }
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: DispatchTime.now().uptimeNanoseconds + UInt64(0.3 *  Double(NSEC_PER_SEC)))) {
            self.tableHeight.constant = self.tableView.contentSize.height
        }
    }
    func parseReviews(json: JSON) {
        for review in json["results"].arrayValue {
            let id = review["id"].stringValue
            let author = review["author"].stringValue
            let content = review["content"].stringValue
            let url = review["url"].stringValue
            let obj = ["id": id, "author": author, "content" : content, "url" : url]
            petitionReviews.append(obj)
            print(review)
        }
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: DispatchTime.now().uptimeNanoseconds + UInt64(0.3 *  Double(NSEC_PER_SEC)))) {
            self.tableHeight.constant = self.tableView.contentSize.height
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? petitionTrailers.count : petitionReviews.count
//        if section == 0 {
//            return petitionTrailers.count
//        }else{
//            return petitionReviews.count
//        }
      //  return  petitionTrailers.count + petitionReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let tit = cell.viewWithTag(1) as? UILabel
        let det = cell.viewWithTag(2) as? UILabel
        
        if indexPath.section == 0 {
            let petitionT = petitionTrailers[indexPath.row]
            /*(cell.viewWithTag(10) as? UITextView)?.text = "Trailer \(indexPath.row + 1): \(petitionT["name"]!)"*/
            
            tit?.text = "Trailer \(indexPath.row + 1):"
            det?.text = "  "+petitionT["name"]!
            
        }else{
            let petitionT = petitionReviews[indexPath.row]
            /*
            (cell.viewWithTag(10) as? UITextView)?.text = "Reviewed by \(petitionT["author"]!) \n \(petitionT["content"]!)"*/
            tit?.text = petitionT["author"]!
            det?.text = "  "+petitionT["content"]!
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Trailers:" : "Reviews:"
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            UIApplication.shared.open(URL(string: "http://www.youtube.com/watch?v=" + petitionTrailers[indexPath.row]["key"]!)!, options: [:], completionHandler: nil)
        }else{
            UIApplication.shared.open(URL(string:  petitionReviews[indexPath.row]["url"]!)!, options: [:], completionHandler: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
  
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 60
        return UITableViewAutomaticDimension
    }
    
}
