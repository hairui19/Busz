//
//  BusStopPinView.swift
//  Busz
//
//  Created by Hairui Lin on 25/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import MapKit

class BusStopPinView: MKAnnotationView {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        image = UIImage(named: "busStopPinImage")
        canShowCallout = true
        rightCalloutAccessoryView = customRightCalloutAccessoryView()
        
    }
    
    func customRightCalloutAccessoryView() -> UIButton{
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 25, height: 41)
        //button.layer.cornerRadius = 23/2
        button.setImage(UIImage(named: "destinationBusStop"), for: .normal)
        return button
    }

}
