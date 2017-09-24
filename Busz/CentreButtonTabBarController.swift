//
//  CentreButtonTabBarController.swift
//  Busz
//
//  Created by Hairui Lin on 24/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import UIKit

class CentreButtonTabBarController: UITabBarController {

    
    private let heightOfTabbar : CGFloat = 49
    override func viewDidLoad() {
        super.viewDidLoad()
        addMiddleButton()
    }
    
    private func addMiddleButton(){
        let customButton = UIButton(type: .custom)
        customButton.backgroundColor = .red
        self.view.addSubview(customButton)
        
        customButton.translatesAutoresizingMaskIntoConstraints = false
        customButton.centerXAnchor.constraint(equalTo: self.tabBar.centerXAnchor, constant: 0).isActive = true
        customButton.centerYAnchor.constraint(equalTo: self.tabBar.centerYAnchor, constant: 0).isActive = true
        customButton.heightAnchor.constraint(equalToConstant: heightOfTabbar).isActive = true
        customButton.widthAnchor.constraint(equalToConstant: heightOfTabbar).isActive = true
    }

}
