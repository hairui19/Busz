//
//  BusSelectionCell.swift
//  Busz
//
//  Created by Hairui Lin on 23/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import UIKit

class BusSelectionCell: UICollectionViewCell {

    @IBOutlet weak var busNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.shadowRadius = 5
        self.layer.shadowColor = Colors.heavyBlue.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.clipsToBounds = false
        self.layer.masksToBounds = false
    }
    
    override func prepareForReuse() {
        busNumberLabel.text = ""
    }

}
