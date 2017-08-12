//
//  UIControllers.swift
//  Project7
//
//  Created by MacPro on 1/14/17.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import UIKit

class UIControllers: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    
    func refreshController(message: String,view: UIScrollView, refresh: Selector) -> UIRefreshControl {
        let refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: message)
        refresher.addTarget(self, action: refresh, for: UIControlEvents.valueChanged)
        view.refreshControl = refresher
        return refresher
    }
    
    func displayAlert(title: String,message:String,ActionTitle: String,viewController: ViewController) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: ActionTitle, style: .default, handler: { (action) in
            viewController.dismiss(animated: true, completion: nil)
        }))
        viewController.present(alert, animated: true, completion: nil)
        return alert
    }
    
    func displayActionSheet(title: String,message:String,ActionTitle: String,viewController: ViewController) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: ActionTitle, style: .default, handler: { (action) in
            viewController.dismiss(animated: true, completion: nil)
        }))
        viewController.present(alert, animated: true, completion: nil)
        return alert
    }
    
    
    
}
