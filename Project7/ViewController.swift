//
//  ViewController.swift
//  Project7
//
//  Created by TwoStraws on 15/08/2016.
//  Copyright © 2016 Paul Hudson. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
	var petitions = [[String: String]]()

	override func viewDidLoad() {
		super.viewDidLoad()

		let urlString: NSURL?

		if navigationController?.tabBarItem.tag == 0 {
            urlString = NSURL(string:"http://api.themoviedb.org/3/movie/popular?api_key=7087d1f9cfd0b1f535b1476c47d371c4")!
		} else {
			urlString = NSURL(string:"http://api.themoviedb.org/3/movie/top_rated?api_key=7087d1f9cfd0b1f535b1476c47d371c4")!
		}
        
		if let url = urlString {
			if let data = try? Data(contentsOf: url as URL) {
				let json = JSON(data: data)
                parse(json: json)
			}
		}
        
	}

	func parse(json: JSON) {
		for result in json["results"].arrayValue {
			let title = result["title"].stringValue
			let overview = result["overview"].stringValue

			let obj = ["title": title, "overview": overview]
			petitions.append(obj)
            print(result)
		}
		tableView.reloadData()
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return petitions.count
	}

    
    
    
    
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

		let petition = petitions[indexPath.row]
		cell.textLabel?.text = petition["name"]
		//cell.detailTextLabel?.text = petition["overview"]

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = DetailViewController()
		//vc.overView = petitions[indexPath.row]
		navigationController?.pushViewController(vc, animated: true)
	}

	func showError() {
		let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default))
		present(ac, animated: true)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

