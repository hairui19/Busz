//
//  Bus.swift
//  Busz
//
//  Created by Hairui Lin on 22/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import CoreLocation

struct Bus {
    let busNumber : String
    let provider : String
    let startingBusStop : String
    var routes : Array<(CLLocationDegrees , CLLocationDegrees)> = []
    var busStops : BusStops = BusStops()
    
    static let dummyBus = Bus(json: [
            "no" : "dummyBusNo"
        ])!
    
    init?(json : [String : Any]) {
        // busNumber essential data
        guard let busNumber = json["no"] as? String else{ return nil }
        
        self.busNumber = busNumber
        self.provider = json["operator"] as? String ?? ""
        self.startingBusStop = json["name"] as? String ?? ""
    }
}
