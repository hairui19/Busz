//
//  BusArrivalCell.swift
//  Busz
//
//  Created by Hairui Lin on 27/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import UIKit
import RxSwift

class BusArrivalCell: UICollectionViewCell {
    let apiClient = APIClient.share
    let disposeBag = DisposeBag()
    @IBOutlet weak var busNumberLabel: UILabel!
    @IBOutlet weak var busStopNameLabel: UILabel!
    @IBOutlet weak var estArrivalLabel: UILabel!
    @IBOutlet weak var busCodeLabel: UILabel!

    
    var busForDisplay : BusForDisplay?{
        didSet{
            busNumberLabel.text = busForDisplay?.busNumber
            busStopNameLabel.text = busForDisplay?.busStopName
            busCodeLabel.text = busForDisplay?.busStopCode
            apiClient.getBusArrivalTimeForDisplay(busStopCode: (busForDisplay?.busStopCode)!, serviceNo: (busForDisplay?.busNumber)!, busStopName: (busForDisplay?.busStopName)!)
            .asObservable()
            .debug()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] estimatedTimeMessage in
                if let estimatedTimeMessage = estimatedTimeMessage {
                    if estimatedTimeMessage == ""{
                        self?.estArrivalLabel.text = "Est Arrival: Arrived"
                    }else{
                        self?.estArrivalLabel.text = "Est Arrival: \(estimatedTimeMessage)"
                    }
                }else{
                    self?.estArrivalLabel.text = "No Data Avail"
                }
            })
            .addDisposableTo(disposeBag)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        busNumberLabel.textColor = Colors.heavyPurple
        busStopNameLabel.textColor = Colors.heavyPurple
        estArrivalLabel.textColor = Colors.heavyPurple
        busCodeLabel.textColor = Colors.heavyPurple
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.shadowRadius = 5
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowColor = Colors.heavyPurple.cgColor
        self.clipsToBounds = false
        self.layer.masksToBounds = false
    }

}
