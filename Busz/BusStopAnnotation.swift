//
//  BusStopAnnotation.swift
//  Busz
//
//  Created by Hairui Lin on 24/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class BusStopAnnotation : NSObject, MKAnnotation {
    let title : String?
    let busStopCode : String
    let coordinate : CLLocationCoordinate2D
    var subtitle: String?{
        return busStopCode
    }
    
    init( busStop : BusStop) {
        title = busStop.name
        busStopCode = busStop.busStopCode
        coordinate = CLLocationCoordinate2D(latitude: busStop.coordinate.0, longitude: busStop.coordinate.1)
        super.init()
    }
}
