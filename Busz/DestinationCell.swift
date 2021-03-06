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
    
    @IBOutlet weak var rightArrowIcon: UIImageView!
    
    var busForDisplay : BusForDisplay?{
        didSet{
            if let bus = busForDisplay{
                busNumberLabel.text = "Bus \(bus.busNumber)"
                busStopNameLabel.text = bus.busStopName
                busStopCode.text = bus.busStopCode
                rightArrowIcon.isHidden = false
                self.isUserInteractionEnabled = true
            }else{
                self.isUserInteractionEnabled = false
                rightArrowIcon.isHidden = true
            }
            
        }
    }
    
    override func prepareForReuse() {
        busNumberLabel.text = ""
        busStopNameLabel.text = ""
        busStopCode.text = ""
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        busNumberLabel.text = ""
        busStopNameLabel.text = ""
        busStopCode.text = ""
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
