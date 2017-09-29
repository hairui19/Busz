//
//  MainViewController+UI.swift
//  Busz
//
//  Created by Hairui Lin on 27/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import UIKit
import CBZSplashView


extension MainViewController{
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !loadedSplashScreen{
            addingASimpleSplashScreen{[weak self] in
                self?.loadedSplashScreen = true
            }
        }
    }
    
    func addingASimpleSplashScreen(_ completion : @escaping ()->()){
        let currentWindow = UIApplication.shared.keyWindow
        let icon = UIImage(named: "BuszIcon")
        let splashView = CBZSplashView.init(icon: icon, backgroundColor: Colors.heavyBlue)
        splashView?.animationDuration = 1.4
        currentWindow?.addSubview(splashView!)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            splashView?.startAnimation()
            completion()
        })
    }
    
    func setupUI(){
        self.navigationItem.title = "Busz"
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = Colors.heavyBlue
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
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
