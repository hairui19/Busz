//
//  DestinationAnnotationManager.swift
//  Busz
//
//  Created by Hairui Lin on 26/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation


struct DestinationAnnotationManager {
    var previousDestionationAnnotation : DestinationBusStopAnnotation?
    var currentDestionationAnnotation : DestinationBusStopAnnotation?
    
    mutating func update( _ destinationAnnotaion : DestinationBusStopAnnotation?){
        previousDestionationAnnotation = currentDestionationAnnotation
        currentDestionationAnnotation = destinationAnnotaion
    }
    
    mutating func remove(){
        previousDestionationAnnotation = currentDestionationAnnotation
        currentDestionationAnnotation = nil
    }
    
    init(){}
}
