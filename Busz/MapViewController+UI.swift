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
        chosenBus
            .asObservable()
            .map { (bus) -> [BusStopAnnotation] in
                return bus.busStops.map({ (busStop) -> BusStopAnnotation in
                    return BusStopAnnotation(title: busStop.name, busStopCode: busStop.busStopCode, coordinate: busStop.coordinate)
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
        chosenBus
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
    
    // setting up pinView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? BusStopAnnotation {
            let identifier = "busStopPin"
            var view : BusStopPinView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? BusStopPinView{
                dequeuedView.annotation = annotation
                view = dequeuedView
            }else{
                view = BusStopPinView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            return view
        }else if let annotation = annotation as? DestinationBusStopAnnotation{
            let identifier = "destionationBusStopPin"
            var view : DestinationBusStopPinView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? DestinationBusStopPinView{
                dequeuedView.annotation = annotation
                view = dequeuedView
            }else{
                view = DestinationBusStopPinView(annotation: annotation, reuseIdentifier: identifier)
            }
            return view
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view is BusStopPinView{
            guard let annotation = view.annotation else{
                return
            }
            mapView.removeAnnotation(annotation)
            let destinationBusStopAnnotation = DestinationBusStopAnnotation(title: (annotation.title ?? "")!, busStopCode: (annotation.subtitle ?? "")!, coordinate: (annotation.coordinate.latitude, annotation.coordinate.longitude))
            mapView.addAnnotation(destinationBusStopAnnotation)
        }
    }
}

