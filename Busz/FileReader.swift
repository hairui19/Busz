//
//  LocalAPIClient.swift
//  Busz
//
//  Created by Hairui Lin on 22/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

class FileReader{
    static let share = FileReader()
    
    private enum FileReaderError : Error{
        case invalidFilename(String)
        case invalidData
    }
    
    //endpoints
    private let busServicesEndpoint = "bus-services"
    private let busStopsServicesEndpoint = "bus-stops-services"
    private let busStopsEndpoint = "bus-stops"
    private func requestFile(name:String, type : String = "json") -> Observable<[String : Any]>{
        do{
            guard let filename = Bundle.main.url(forResource: name, withExtension: type) else{
                    throw FileReaderError.invalidFilename(name)
            }
            let data = try Data(contentsOf: filename)
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),let result = jsonObject as? [String : Any] else{
                throw FileReaderError.invalidData
            }
            return Observable<[String : Any]>.just(result).shareReplay(1)
            
        }catch FileReaderError.invalidData{
            print("data")
        }catch FileReaderError.invalidFilename(let value){
            print("invalidFilename : \(value)")
        }catch{
            print("hello world")
        }
        return Observable.empty()
    }
    
    private func requestFileInArrayFormat(name:String, type : String = "json") -> Observable<[Any]>{
        do{
            guard let filename = Bundle.main.url(forResource: name, withExtension: type) else{
                throw FileReaderError.invalidFilename(name)
            }
            let data = try Data(contentsOf: filename)
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),let result = jsonObject as? [Any] else{
                throw FileReaderError.invalidData
            }
            return Observable<[Any]>.just(result).shareReplay(1)
            
        }catch FileReaderError.invalidData{
            print("data")
        }catch FileReaderError.invalidFilename(let value){
            print("invalidFilename : \(value)")
        }catch{
            print("hello world")
        }
        return Observable.empty()
    }
    
    // types of buses.
    
    
    func busServices() -> Observable<[Bus]> {
        return requestFile(name: busServicesEndpoint).map {dataDic -> [Bus] in
            guard let busServices = dataDic["services"] as? [[String : Any]] else{
                return [Bus]()
            }
            return busServices.flatMap(Bus.init)
        }
        .shareReplay(1)
    }
    
     func busStops() -> Observable<[String : Any]>{
         var allBusStopsDic = [String : Any]()
        return requestFileInArrayFormat(name: busStopsEndpoint).map({ data -> [String : Any] in
            guard let data = data as? [[String : Any]] else {return allBusStopsDic}
            for singleBusStop in data {
                guard let busStopCode = singleBusStop["no"] as? String,
                    let lat = singleBusStop["lat"] as? String,
                    let lng = singleBusStop["lng"] as? String,
                    let busStopName = singleBusStop["name"] as? String else{continue}
                allBusStopsDic[busStopCode] = [
                    "lat" : lat,
                    "lng" : lng,
                    "name" : busStopName
                ]
            }
            return allBusStopsDic
        })
        .shareReplay(1)
    }
    
    func routeFor(bus: Bus) -> Observable<Bus>{
        let busStopsObservable = self.busStops()
        let routeObservable = requestFile(name: bus.busNumber)
        return Observable.combineLatest(busStopsObservable, routeObservable) {busStopsDic, routeData -> Bus in
            var updatedBus = bus
            if let route1 = routeData["1"] as? [String : Any], let route = route1["route"] as? [String], let busStopCodes = route1["stops"] as? [String] {
                _ = busStopCodes.map({ stopCode -> Void in
                    let busStopInfo = busStopsDic[stopCode] as? [String : Any]
                    if let busStop = BusStop(busStopCode: stopCode, busStopInfo: busStopInfo!){
                        updatedBus.busStops.append(busStop)
                    }
                })
                _ = route.map({ coordinateString -> Void in
                    let coodinate = coordinateString.components(separatedBy: ",")
                    let coordinateTuple = (CLLocationDegrees(coodinate[0])!, CLLocationDegrees(coodinate[1])!)
                    updatedBus.routes.append(coordinateTuple)
                })
            }
            
            return updatedBus
        }
        .shareReplay(1)
        
    }
    
}
