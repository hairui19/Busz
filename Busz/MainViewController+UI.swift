//
//  MainViewController+UI.swift
//  Busz
//
//  Created by Hairui Lin on 27/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import UIKit


extension MainViewController{
    func setupUI(){
        setCollectionView()
    }
    
    fileprivate func setCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "BusArrivalCell", bundle: nil), forCellWithReuseIdentifier: Identifiers.kBusArrivalCell)
        collectionView.register(UINib(nibName: "DestinationCell", bundle: nil), forCellWithReuseIdentifier: Identifiers.kDestinationCell)
        collectionView.register(UINib(nibName: "BusArrivalHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Identifiers.kBusArrivalHeader)
        collectionView.contentInset = UIEdgeInsets(top: 35, left: 0, bottom: 35, right: 0)
        collectionViewFlowLayout.minimumLineSpacing = 13
    }
}
