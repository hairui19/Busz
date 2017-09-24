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
}
