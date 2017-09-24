//
//  CentreButtonTabBarController.swift
//  Busz
//
//  Created by Hairui Lin on 24/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import UIKit

class CentreButtonTabBarController: UITabBarController {

    private let imageDimension : CGFloat = 70
    private let heightOfTabbar : CGFloat = 49

    override func viewDidLoad() {
        super.viewDidLoad()
        addMiddleButton()
    }
    
    private func addMiddleButton(){
        
        //add image view
        let iconImage = UIImage(named: "busButtonIcon")
        let imageView = UIImageView(image: iconImage)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageDimension / 2
        self.tabBar.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: self.tabBar.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: imageDimension).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageDimension).isActive = true
        let bottomPadding = heightOfTabbar - (imageDimension/2)
        imageView.bottomAnchor.constraint(equalTo: self.tabBar.bottomAnchor, constant: -bottomPadding).isActive = true
        
    }

}
