//
//  BusSelectionViewController.swift
//  Busz
//
//  Created by Hairui Lin on 23/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BusSelectionViewController: UIViewController {

    
    // MARK: - Properties
    fileprivate let busSelectionCell = "BusSelectionCell"
    fileprivate let fileReader = FileReader()
    fileprivate let buses = Variable<[Bus]>([])
    fileprivate let disposeBag = DisposeBag()
    // IBOulets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUItoRx()
        //register cell for uicollectionview.
        collectionView.register(UINib(nibName: "BusSelectionCell", bundle: nil), forCellWithReuseIdentifier: busSelectionCell)
    }

}

//MARK: - RXSwift and RxCocoa
extension BusSelectionViewController{
    func bindUItoRx(){
        fileReader.busServices()
            .bind(to: buses)
            .addDisposableTo(disposeBag)
        
        buses.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self ]_ in
                self?.collectionView.reloadData()
            })
            .addDisposableTo(disposeBag)
    }
}

//MARK: - UICollectionViewDelegate and DataSource
extension BusSelectionViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buses.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: busSelectionCell, for: indexPath) as! BusSelectionCell
        let bus = buses.value[indexPath.row]
        cell.busNumberLabel.text = bus.busNumber
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bus = buses.value[indexPath.row]
        fileReader.busStops().subscribe()
        fileReader.routeFor(bus: bus)
            .subscribe()
       
    }
}
