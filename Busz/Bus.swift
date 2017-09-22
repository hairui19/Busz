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
    let direction : Int
    let provider : String
    let type : BusType
    var routes : Array<(CLLocationDegrees , CLLocationDegrees)> = []
    var busStops : Array<String> = []
    
    enum BusType {
        case trunkBusServices
        case feederBusServices
        case niteBusServices
        case unknown
    }
    
    init?(json : [String : Any], busType : String) {
        guard let busNumber = json["no"] as? String,
            let direction = json["dir"] as? NSNumber,
            let provider = json["provider"] as? String else{
                return nil
        }
        
        self.busNumber = busNumber
        self.direction = direction.intValue
        self.provider = provider
        
        switch busType {
        case "Trunk Bus Services":
            self.type = .trunkBusServices
        case "Feeder Bus Services":
            self.type = .feederBusServices
        case "Nite Bus Services":
            self.type = .niteBusServices
        default:
            self.type = .unknown
            break
        }
    }
}
