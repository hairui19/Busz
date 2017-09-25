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
    }

}
