//
//  MapViewController+UI.swift
//  Busz
//
//  Created by Hairui Lin on 22/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import UIKit

extension MapViewController{
    func setupUI(){
        setWhiteBox()
        setPicker()
    }
    
    func setWhiteBox(){
        whiteBox.layer.cornerRadius = 10
        whiteBox.layer.shadowColor = UIColor.lightGray.cgColor
        whiteBox.layer.shadowOffset = CGSize(width: 1, height: 2)
        whiteBox.layer.shadowRadius = 5;
        whiteBox.layer.shadowOpacity = 1
    }
    
    func setPicker(){
        destinationPicker.delegate = self
        destinationPicker.dataSource = self
    }
    
}
