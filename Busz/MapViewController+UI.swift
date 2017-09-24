//
//  MapViewController+UI.swift
//  Busz
//
//  Created by Hairui Lin on 22/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

extension MapViewController{
    func setupUI(){
        setWhiteBox()
        setPicker()
    }
    
    fileprivate func setWhiteBox(){
        whiteBox.layer.cornerRadius = 10
        whiteBox.layer.shadowColor = UIColor.lightGray.cgColor
        whiteBox.layer.shadowOffset = CGSize(width: 1, height: 2)
        whiteBox.layer.shadowRadius = 5;
        whiteBox.layer.shadowOpacity = 1
    }
    
    fileprivate func setPicker(){
        destinationPicker.delegate = self
        destinationPicker.dataSource = self
        destinationPicker.isHidden = true
    }
    
}

//MAR: - Map & CoreLocation Functions
extension MapViewController : CLLocationManagerDelegate, MKMapViewDelegate {
     func initializingMap(){
        mapView.delegate = self
        mapView.showsUserLocation = (CLLocationManager.authorizationStatus() == .authorizedAlways)
        addBusAnnotations()
        addPolyLineForRoute()
    }
    
    fileprivate func addBusAnnotations(){
        //plot all the bus stops
        choseBus
            .asObservable()
            .map { (bus) -> [BusStopAnnotation] in
                return bus.busStops.map({ (busStop) -> BusStopAnnotation in
                    return BusStopAnnotation(busStop: busStop)
                })
            }
            .subscribe(onNext: { [weak self] busAnnotations in
                for busAnnotation in busAnnotations {
                    self?.mapView.addAnnotation(busAnnotation)
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func addPolyLineForRoute(){
        choseBus
            .asObservable()
            .map { bus -> [CLLocationCoordinate2D] in
                return bus.routes.map({ (altitude, longtitude) -> CLLocationCoordinate2D in
                    return CLLocationCoordinate2D(latitude: altitude, longitude: longtitude)
                })
            }
            .subscribe(onNext: { [weak self] coordinates in
                var coords = coordinates
                let polyline = MKPolyline(coordinates: &coords, count: coords.count)
                self?.mapView.add(polyline)
            })
            .addDisposableTo(disposeBag)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = Colors.pink
        polylineRenderer.lineWidth = 2
        print("here i am casss")
        return polylineRenderer
    }
}

