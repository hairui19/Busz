//
//  Utility.swift
//  Busz
//
//  Created by Hairui Lin on 24/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import UIKit

struct Utility {
    static func showAlert(in viewcontroller :UIViewController, title : String, message : String = ""){
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertViewController.addAction(action)
        viewcontroller.present(alertViewController, animated: true, completion: nil)
    }
    
    static func showAlert(in viewController : UIViewController, title : String, message : String, addAction : @escaping ()->()){
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { action in
            addAction()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertViewController.addAction(addAction)
        alertViewController.addAction(cancelAction)
        viewController.present(alertViewController, animated: true, completion: nil)
    }
}
