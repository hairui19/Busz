//
//  ViewController.swift
//  Busz
//
//  Created by Hairui Lin on 22/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {

    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var arrivalTimesImageView: UIImageView!
    @IBOutlet weak var pastDestinationsImageView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var isBusArrivalTab = false
    
    //private let apiClient = APIClient.share
    private let fileReader = FileReader.share
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

extension MainViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isBusArrivalTab{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.kBusArrivalCell, for: indexPath) as! BusArrivalCell
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.kDestinationCell, for: indexPath)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height : CGFloat = 75
        let width = collectionView.frame.size.width - 30
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Identifiers.kBusArrivalHeader, for: indexPath) as! BusArrivalHeader
        headerview.titleLabel.text = "Hairui"
        return headerview
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 70, height: 60)
    }
}

