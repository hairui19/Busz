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
    
    
    // Errors
    private enum APIError : Error{
        case invalidURL(String)
        case invalidJSON(String)
    }
    
    private func request(endpoint : String) -> Observable<[String : Any]>{
        do{
            guard let url = URL(string: baseURL)?.appendingPathComponent(endpoint) else{
                throw APIError.invalidURL(endpoint)
            }
            
            var request = URLRequest(url: url)
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
                print("everything ok")
                return result
            })
            
        }catch{
            print("something error has happened")
            return Observable.empty()
        }
    }
    
    func busRoutes()-> Observable<[String : Any]>{
        return request(endpoint: busStopsEndpoint)
    }
}
