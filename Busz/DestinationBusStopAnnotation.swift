//
//  DestinationBusStopAnnotation.swift
//  Busz
//
//  Created by Hairui Lin on 25/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import MapKit

class DestinationBusStopAnnotation: NSObject, MKAnnotation {
    let title : String?
    let busStopCode : String
    let coordinate : CLLocationCoordinate2D
    var subtitle: String?{
        return busStopCode
    }
    
    init(title : String, busStopCode : String, coordinate : (CLLocationDegrees,CLLocationDegrees )){
        self.title = title
        self.busStopCode = busStopCode
        self.coordinate = CLLocationCoordinate2D(latitude: coordinate.0, longitude: coordinate.1)
    }
}
