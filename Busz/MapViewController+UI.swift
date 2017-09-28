//
//  MapViewController+UI.swift
//  Busz
//
//  Created by Hairui Lin on 22/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

extension MapViewController{
    func setupUI(){
        setWhiteBox()
        setPicker()
        setTurnOffAlarmUI()
    }
    
    fileprivate func setWhiteBox(){
        whiteBox.layer.cornerRadius = 10
        whiteBox.layer.shadowColor = UIColor.lightGray.cgColor
        whiteBox.layer.shadowOffset = CGSize(width: 1, height: 2)
        whiteBox.layer.shadowRadius = 5;
        whiteBox.layer.shadowOpacity = 1
    }
    
    fileprivate func setPicker(){
        destinationPicker.delegate = self
        destinationPicker.dataSource = self
        destinationPicker.isHidden = true
    }
    
    fileprivate func setTurnOffAlarmUI(){
        turnOffAlarmButton.backgroundColor = .white
        turnOffAlarmButton.layer.cornerRadius = 5
        turnOffAlarmButton.layer.shadowRadius = 5
        turnOffAlarmButton.layer.shadowColor = UIColor.lightGray.cgColor
        turnOffAlarmButton.layer.shadowOpacity = 1
        turnOffAlarmButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        turnOffAlarmButton.clipsToBounds = false
        turnOffAlarmButton.layer.masksToBounds = false
    }
    
}



