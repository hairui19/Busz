//
//  DestinationCell.swift
//  Busz
//
//  Created by Hairui Lin on 28/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import UIKit

class DestinationCell: UICollectionViewCell {

    @IBOutlet weak var busNumberLabel: UILabel!
    
    @IBOutlet weak var busStopNameLabel: UILabel!
    
    @IBOutlet weak var busStopCode: UILabel!
    
    
    var busForDisplay : BusForDisplay?{
        didSet{
            busNumberLabel.text = "Bus \(busForDisplay!.busNumber)"
            busStopNameLabel.text = busForDisplay?.busStopName
            busStopCode.text = busForDisplay?.busStopCode
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        busNumberLabel.textColor = Colors.mediumPuprple
        busStopNameLabel.textColor = Colors.mediumPuprple
        busStopCode.textColor = Colors.mediumPuprple
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.shadowRadius = 5
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowColor = Colors.mediumPuprple.cgColor
        self.clipsToBounds = false
        self.layer.masksToBounds = false
    }

}
