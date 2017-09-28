//
//  APIClient.swift
//  Busz
//
//  Created by Hairui Lin on 22/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class APIClient {
    static let share = APIClient()
    private init(){}
    
    // Base URL
    private let baseURL = "http://datamall2.mytransport.sg/ltaodataservice"
    
    // Endpoints
    private let busRouteEndpoint = "BusRoutes"
    private let busServicesEndpoint = "BusServices"
    private let busStopsEndpoint = "BusStops"
    private let busArrivalTimeEndpoint = "BusArrivalv2"
    
    
    // Errors
    private enum APIError : Error{
        case invalidURL(String)
        case invalidJSON(String)
        case invalidParams(String, Any)
    }
    
    private func request(endpoint : String, params : [String : Any] = [:]) -> Observable<[String : Any]>{
        do{
            guard let url = URL(string: baseURL)?.appendingPathComponent(endpoint),
                var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
            else{
                throw APIError.invalidURL(endpoint)
            }
            
            urlComponents.queryItems = try params.map({ (key, value) -> URLQueryItem in
                guard let v = value as? CustomStringConvertible else{
                    throw APIError.invalidParams(key, value)
                }
                return URLQueryItem(name: key, value: v.description)
            })
            
            let finalURL = urlComponents.url!
            var request = URLRequest(url: finalURL)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("lNquaoFlRWG4yXRGQNXYhg==", forHTTPHeaderField: "AccountKey")
            request.httpMethod = "GET"
            
            return URLSession.shared.rx.response(request: request).map({ (response, data) -> [String : Any] in
                guard (200..<300 ~= response.statusCode) else{
                    throw APIError.invalidURL(url.absoluteString)
                }
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),let result = jsonObject as? [String : Any] else{
                    throw APIError.invalidJSON(url.absoluteString)
                }
                return result
            })
            
        }catch{
            print("something error has happened")
            return Observable.empty()
        }
    }
    
    func getBusArrivalTime(busStopCode : String, serviceNo : String, busStopName : String) -> Observable<String?>{
        let params = [
            "BusStopCode" : busStopCode,
            "ServiceNo" : serviceNo
        ]
        return request(endpoint: busArrivalTimeEndpoint, params: params)
            .map({ dataDic -> String? in
                guard let services = dataDic["Services"] as? [Any],
                    services.count > 0,
                    let nextBus = services[0] as? [String : Any],
                let nextBusInfo = nextBus["NextBus"] as? [String : Any],
                let estimatedArrival = nextBusInfo["EstimatedArrival"] as? String else{
                        return nil
                }
                let arrivalTime = estimatedArrival
                let dateFormatter = ISO8601DateFormatter()
                let date: Date? = dateFormatter.date(from: arrivalTime)
                if let theArrivingDate = date{
                    let arrivingTime = theArrivingDate.offsetFrom(date: Date())
                    if arrivingTime == ""{
                        return "Bus \(serviceNo) has arrived at \(busStopName)"
                    }else{
                        return "Bus \(serviceNo) is arriving at \(busStopName) in \(arrivingTime)"
                    }
                }else{
                    return nil
                }
                
            })
    }
    
    func getBusArrivalTimeForDisplay(busStopCode : String, serviceNo : String, busStopName : String) -> Observable<String?>{
        let params = [
            "BusStopCode" : busStopCode,
            "ServiceNo" : serviceNo
        ]
        return request(endpoint: busArrivalTimeEndpoint, params: params)
            .map({ dataDic -> String? in
                guard let services = dataDic["Services"] as? [Any],
                    services.count > 0,
                    let nextBus = services[0] as? [String : Any],
                    let nextBusInfo = nextBus["NextBus"] as? [String : Any],
                    let estimatedArrival = nextBusInfo["EstimatedArrival"] as? String else{
                        return nil
                }
                let arrivalTime = estimatedArrival
                let dateFormatter = ISO8601DateFormatter()
                let date: Date? = dateFormatter.date(from: arrivalTime)
                if let theArrivingDate = date{
                    let arrivingTime = theArrivingDate.offsetFrom(date: Date())
                    if arrivingTime == ""{
                        return ""
                    }else{
                        return arrivingTime
                    }
                }else{
                    return nil
                }
                
            })
    }
    
    
}

