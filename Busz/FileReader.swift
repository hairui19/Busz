//
//  LocalAPIClient.swift
//  Busz
//
//  Created by Hairui Lin on 22/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import RxSwift

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
            guard let filename = Bundle.main.path(forResource: name, ofType: type),
                let url = URL(string: filename) else{
                    throw FileReaderError.invalidFilename(name)
            }
            
            let data = try Data(contentsOf: url)
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),let result = jsonObject as? [String : Any] else{
             
                throw FileReaderError.invalidData
            }
            return Observable<[String : Any]>.just(result)
            
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
        let trunkBuses = "Trunk Bus Services"
        let feederBuses = "Feeder Bus Services"
        let niteBuses = "Nite Bus Services"
        return requestFile(name: busServicesEndpoint).map {dataDic -> [Bus] in
            var allBuses : [Bus] = []
            guard let trunkBusesArray = dataDic[trunkBuses] as? [[String : Any]],
                let feederBusesArray = dataDic[feederBuses] as? [[String : Any]],
                let niteBusesArray = dataDic[niteBuses] as? [[String : Any]] else{
                    return allBuses
            }
            
            allBuses += trunkBusesArray.flatMap({ json -> Bus? in
                return Bus.init(json: json, busType:feederBuses)
            })
            
            allBuses += feederBusesArray.flatMap({ json -> Bus? in
                return Bus.init(json: json, busType:trunkBuses)
            })
            
            allBuses += niteBusesArray.flatMap({ json -> Bus? in
                return Bus.init(json: json, busType:niteBuses)
            })
            
            return allBuses
        }
    }
    
}
