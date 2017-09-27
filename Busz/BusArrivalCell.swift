//
//  BusArrivalCell.swift
//  Busz
//
//  Created by Hairui Lin on 27/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import UIKit

class BusArrivalCell: UICollectionViewCell {
    @IBOutlet weak var busNumberLabel: UILabel!
    @IBOutlet weak var busStopNameLabel: UILabel!
    @IBOutlet weak var estArrivalLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
