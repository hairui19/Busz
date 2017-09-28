//
//  BusForTimeArrival.swift
//  Busz
//
//  Created by Hairui Lin on 28/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import RealmSwift

class BusForTimeArrival: Object {
    dynamic var busNumber = ""
    dynamic var busStopCode = ""
    dynamic var busStopName = ""
    dynamic var timeStamp : Double = 0.0
}
