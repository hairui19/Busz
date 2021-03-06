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
        guard let lat = busStopInfo["lat"] as? String,let lng = busStopInfo["lng"] as? String, let name = busStopInfo["name"] as? String else{
            return nil
        }
        
        guard let altitude = CLLocationDegrees(lat),
            let longitude = CLLocationDegrees(lng) else{
                return nil
        }
        
        self.busStopCode = busStopCode
        self.name = name
        self.coordinate = ((altitude * 10000000).rounded(.down)/10000000,(longitude * 10000000).rounded(.down)/10000000)
    }
    
}
