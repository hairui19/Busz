//
//  BusSelectionViewController+UI.swift
//  Busz
//
//  Created by Hairui Lin on 23/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import UIKit

extension BusSelectionViewController{
     func setupUI(){
        setCollectionViewUI()
        setSearchBarUI()
    }
    
    fileprivate func setCollectionViewUI(){
        collectionView.delegate = self
        collectionView.dataSource = self
        let image = UIImage(named: "busSelectionBG")
        let imageView = UIImageView(image: image)
        collectionView.backgroundView = imageView
    }
    
    fileprivate func setSearchBarUI(){
        searchBar.barTintColor = Colors.lightGreen
        searchBar.layer.borderColor = UIColor.clear.cgColor
        searchBar.layer.shadowColor = UIColor.clear.cgColor
    }
    
    
}
