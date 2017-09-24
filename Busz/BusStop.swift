//
//  BusStop.swift
//  Busz
//
//  Created by Hairui Lin on 23/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import CoreLocation

struct BusStop {
    let busStopCode : String
    let coordinate : (CLLocationDegrees, CLLocationDegrees)
    let name : String
    
    
    init?(busStopCode : String, busStopInfo : [String : Any]) {
        guard let coordinateStr = busStopInfo["coords"] as? String, let name = busStopInfo["name"] as? String else{
            return nil
        }
        let coordinateArray = coordinateStr.components(separatedBy: ",")
        guard let altitude = CLLocationDegrees(coordinateArray[1]),
            let longitude = CLLocationDegrees(coordinateArray[0]) else{
                return nil
        }
        self.busStopCode = busStopCode
        self.name = name
        self.coordinate = (altitude,longitude)
    }
}
