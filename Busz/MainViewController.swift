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
import Foundation

class MainViewController: UIViewController {

    
    //MARK: - Properties
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var arrivalTimesImageView: UIImageView!
    @IBOutlet weak var pastDestinationsImageView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var isBusArrivalTab = true
    fileprivate var buses : [BusForDisplay] = []
    fileprivate var currentDestination : BusForDisplay?
    
    //private let apiClient = APIClient.share
    private let fileReader = FileReader.share
    
    //MARK: - Life Cycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUpClicksOnImages()
        pullToRefresh()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isBusArrivalTab{
            buses = Utility.readBusesForArrivals()
        }else{
            buses = Utility.readBusesForDestinations()
        }
        collectionView.reloadData()
    }
    
    private func setUpClicksOnImages(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(arrivalTimesTapped))
        arrivalTimesImageView.addGestureRecognizer(tapGesture)
        arrivalTimesImageView.isUserInteractionEnabled = true
        arrivalTimesImageView.image = UIImage(named: "arrivalTimesTapped")
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(destinationTapped))
        pastDestinationsImageView.addGestureRecognizer(tapGesture1)
        pastDestinationsImageView.isUserInteractionEnabled = true
        
    }
    
    func arrivalTimesTapped(){
        isBusArrivalTab = true
        arrivalTimesImageView.image = UIImage(named: "arrivalTimesTapped")
        arrivalTimesImageView.isUserInteractionEnabled = false
        pastDestinationsImageView.isUserInteractionEnabled = true
        pastDestinationsImageView.image = UIImage(named: "pastDestinations")
        buses = Utility.readBusesForArrivals()
        collectionView.reloadData()
       
    }
    
    func destinationTapped(){
        isBusArrivalTab = false
        arrivalTimesImageView.image = UIImage(named: "arrivalTimes")
        arrivalTimesImageView.isUserInteractionEnabled = true
        pastDestinationsImageView.isUserInteractionEnabled = false
        pastDestinationsImageView.image = UIImage(named: "destinationsTapped")
        buses = Utility.readBusesForDestinations()
        collectionView.reloadData()
    }
    
    func pullToRefresh(){
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.refreshControl?.backgroundColor = .clear
    }
    
    func refresh(){
        collectionView.reloadData()
        collectionView.refreshControl?.endRefreshing()
    }
}

extension MainViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if isBusArrivalTab {
            return 1
        }else{
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 && !isBusArrivalTab{
            return 1
        }
        return buses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isBusArrivalTab{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.kBusArrivalCell, for: indexPath) as! BusArrivalCell
            cell.busForDisplay = buses[indexPath.row]
            
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.kDestinationCell, for: indexPath) as! DestinationCell
        if indexPath.section == 1{
            cell.busForDisplay = buses[indexPath.row]
        }else{
            cell.busForDisplay = Utility.readAlarmBusStop()
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height : CGFloat = 75
        let width = collectionView.frame.size.width - 30
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Identifiers.kBusArrivalHeader, for: indexPath) as! BusArrivalHeader
        if isBusArrivalTab{
            headerview.titleLabel.text = "Arrival Time"
            headerview.titleLabel.textColor = Colors.heavyPurple
        }else{
            if indexPath.section == 0 {
                headerview.titleLabel.text = "Current Destination"
            }else{
                headerview.titleLabel.text = "Past Destinations"
                
            }
            headerview.titleLabel.textColor = Colors.mediumPuprple
        }
        return headerview
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 70, height: 60)
    }
}

