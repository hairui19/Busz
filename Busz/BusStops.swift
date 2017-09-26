//
//  BusStops.swift
//  Busz
//
//  Created by Hairui Lin on 26/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation


struct BusStops {
    var normalStops : [BusStop]
    let destinationBusStop : BusStop?
    
    init(){
        normalStops = []
        destinationBusStop = nil
    }
}
