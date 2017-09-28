//
//  Utility.swift
//  Busz
//
//  Created by Hairui Lin on 24/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

struct Utility {
    
    
    static func showAlert(in viewcontroller :UIViewController, title : String, message : String = ""){
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertViewController.addAction(action)
        viewcontroller.present(alertViewController, animated: true, completion: nil)
    }
    
    static func showAlert(in viewController : UIViewController, title : String, message : String, addAction : @escaping ()->()){
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add", style: .default) { action in
            addAction()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertViewController.addAction(addAction)
        alertViewController.addAction(cancelAction)
        viewController.present(alertViewController, animated: true, completion: nil)
    }
    
    static func saveBusForArrival(busNumber : String, busStopCode : String, busStopName : String){
        DispatchQueue.global(qos: .background).async {
            let realm = try! Realm()
            let busesForTimeArrival = realm.objects(BusForTimeArrival.self).sorted(by: { (first, second) -> Bool in
                return first.timeStamp < second.timeStamp
            })
            
            let busForTimeArrival = BusForTimeArrival()
            busForTimeArrival.busNumber = busNumber
            busForTimeArrival.busStopCode = busStopCode
            busForTimeArrival.busStopName = busStopName
            busForTimeArrival.timeStamp = Date().timeIntervalSince1970
            
            try! realm.write {
                if busesForTimeArrival.count == 5{
                    let objectToBeDeleted = busesForTimeArrival[0]
                    realm.delete(objectToBeDeleted)
                }
                realm.add(busForTimeArrival)
            }
        }
    }
    
    static func saveBusForDestinations(busNumber : String, busStopCode : String, busStopName : String){
        DispatchQueue.global(qos: .background).async {
            let realm = try! Realm()
            let busesForDestinations = realm.objects(BusForDestinations.self).sorted(by: { (first, second) -> Bool in
                return first.timeStamp < second.timeStamp
            })
            
            let busDestination = BusForDestinations()
            busDestination.busNumber = busNumber
            busDestination.busStopCode = busStopCode
            busDestination.busStopName = busStopName
            busDestination.timeStamp = Date().timeIntervalSince1970
            
            try! realm.write {
                if busesForDestinations.count == 5{
                    let objectToBeDeleted = busesForDestinations[0]
                    realm.delete(objectToBeDeleted)
                }
                realm.add(busDestination)
            }
        }
    }
    
    static func readBusesForArrivals()->[BusForDisplay]{
        let realm = try! Realm()
        let busesForTimeArrival = realm.objects(BusForTimeArrival.self).sorted(by: { (first, second) -> Bool in
            return first.timeStamp < second.timeStamp
        })
        var busesForDisplay = [BusForDisplay]()
        if busesForTimeArrival.count == 0 {return busesForDisplay}
        for busForTimeArrival in busesForTimeArrival{
            let busForDisplay = BusForDisplay(busNumber: busForTimeArrival.busNumber, busStopCode: busForTimeArrival.busStopCode, busStopName: busForTimeArrival.busStopName)
            busesForDisplay.append(busForDisplay)
        }
        return busesForDisplay
    }
    
    static func readBusesForDestinations() -> [BusForDisplay]{
        let realm = try! Realm()
        let busesForDestinations = realm.objects(BusForDestinations.self).sorted(by: { (first, second) -> Bool in
            return first.timeStamp < second.timeStamp
        })
        var busesForDisplay = [BusForDisplay]()
        if busesForDestinations.count == 0 {return busesForDisplay}
        for busForDestination in busesForDestinations{
            let busForDisplay = BusForDisplay(busNumber: busForDestination.busStopName, busStopCode: busForDestination.busStopCode, busStopName: busForDestination.busStopName)
            busesForDisplay.append(busForDisplay)
        }
        return busesForDisplay
    }
    
}
