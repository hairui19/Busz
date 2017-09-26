//
//  MapViewController.swift
//  Busz
//
//  Created by Hairui Lin on 22/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import UIKit
import MapKit
import RxCocoa
import RxSwift
import CoreLocation
import UserNotifications

class MapViewController: UIViewController {
    
    // MARK: - Properties
    
    fileprivate let busStops = Variable<[BusStop]>([])
    fileprivate let destinationsDescrip = Variable<[String]>([])
    fileprivate let destinationAnnotationManager = Variable<DestinationAnnotationManager>(DestinationAnnotationManager())
    
    let disposeBag = DisposeBag()
    fileprivate let fileReader = FileReader()
    fileprivate let locationManager = CLLocationManager()
    
    //input
    let chosenBus = Variable<Bus>(Bus.dummyBus)
    fileprivate let notificationRadius : CLLocationDegrees = 150
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var destinationPicker: UIPickerView!
    @IBOutlet weak var whiteBox: UIView!
    @IBOutlet weak var destinationTextfield: UITextField!
    @IBOutlet weak var whiteBoxBottomContraint: NSLayoutConstraint!
    
    
    // MARK: - Life Cycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupUI()
        addNotifications()
        addTapToDismissEditingGesture()
        initializingMap()
        binding()
    }
    
    deinit {
        removeNotifications()
    }
    
    // MARK: IBActions.
    @IBAction func setAlarmButtonPressed(_ sender: UIButton) {
    }
    
    
    // MARK: - Animation Function
    fileprivate func addAnimation(animationTime : TimeInterval, layoutChanges : @escaping ()->()){
        UIView.animate(withDuration: animationTime) {
            layoutChanges()
        }
    }
    
    // MARK: - Helper Functions
    fileprivate func loadData(){
        fileReader.routeFor(bus: chosenBus.value)
            .bind(to: chosenBus)
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func getRowForSearchText(searchText : String) -> Int{
        var index = 0
        for data in destinationsDescrip.value{
            if data.lowercased().range(of: searchText.lowercased()) != nil {
                return index
            }else{
                index += 1
            }
        }
        return -1
    }
    
    fileprivate func zoomToLocation(with coordinate : CLLocationCoordinate2D){
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        mapView.setRegion(region, animated: true)
    }
    
}

//MARK: - RxSwift and Bidning
extension MapViewController{
    
    fileprivate func binding(){
        bindingData()
        bindingUI()
    }
    fileprivate func bindingData(){
        chosenBus
            .asObservable()
            .map { bus -> [String] in
                return bus.busStops.normalStops.map({ (busStop) -> String in
                    return busStop.name
                })
            }
            .bind(to: destinationsDescrip)
            .addDisposableTo(disposeBag)
        
        chosenBus
            .asObservable()
            .map { bus -> [BusStop] in
                return bus.busStops.normalStops
            }
            .bind(to: busStops)
            .addDisposableTo(disposeBag)
        
        chosenBus
            .asObservable()
            .map{bus -> BusStop? in
                return bus.busStops.destinationBusStop
            }
            .filter({return ($0 != nil)})
            .subscribe(onNext: { [weak self] destinationBusStop in
                let destionationAnnotation = DestinationBusStopAnnotation(title: destinationBusStop!.name, busStopCode: destinationBusStop!.busStopCode, coordinate: destinationBusStop!.coordinate)
                self?.destinationAnnotationManager.value.update(destionationAnnotation)
            })
            .addDisposableTo(disposeBag)
        
       
    }
    
    fileprivate func bindingUI(){
        (destinationTextfield.rx.text)
            .asObservable()
            .filter{ return ($0 ?? "").characters.count > 0 }
            
            .map { [weak self] searchText -> Int in
                return self!.getRowForSearchText(searchText: searchText!)
            }
            .filter { rowIndex -> Bool in
                if rowIndex < 0 {return false}
                return true
            }
            .subscribe(onNext: {[weak self] rowIndex in
                self!.destinationPicker.selectRow(rowIndex, inComponent: 0, animated: true)
            })
            .addDisposableTo(disposeBag)
        
        
        //[.editingDidBegin, .editingDidEnd]
        let isTextFiledInEditing = Observable.from([
            destinationTextfield.rx.controlEvent(.editingDidBegin).asObservable().map{_ in return false}.asObservable(),
            destinationTextfield.rx.controlEvent(.editingDidEnd).asObservable().map{ _ in return true}.asObservable()
            ])
            .merge()
            .startWith(true)
        // hides picker when not editing, shows otherwise.
        isTextFiledInEditing
            .asObservable()
            .bind(to: destinationPicker.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        // Whenever user taps search or dismiss keyboard.
        // The map zooms in to the destination on the textfield.
        Observable.from([
            destinationTextfield.rx.controlEvent(.editingDidEnd).asObservable(),
            destinationTextfield.rx.controlEvent(.editingDidEndOnExit).asObservable()
            ])
            .merge()
            .map({[weak self] _ -> String? in
                return self?.destinationTextfield.text
            })
            .filter{return ($0 ?? "").characters.count > 0}
            .map { [weak self] text -> Int in
                return (self?.getRowForSearchText(searchText: text!))!
            }
            .subscribe(onNext: { [weak self] index in
                if index == -1 {
                    Utility.showAlert(in: self!, title: "Cannot find the destionation")
                }else{
                    let selectedBusStop = self!.busStops.value[index]
                    let coordinateTuple = selectedBusStop.coordinate
                    let destinationBusStopAnnotation = DestinationBusStopAnnotation(title: selectedBusStop.name, busStopCode: selectedBusStop.busStopCode, coordinate: coordinateTuple)
                    self?.destinationAnnotationManager.value.update(destinationBusStopAnnotation)
                    
                    self?.zoomToLocation(with: CLLocationCoordinate2D(latitude: coordinateTuple.0, longitude: coordinateTuple.1))
                }
            })
            .addDisposableTo(disposeBag)
        
        
        // adding polyline for routes
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
        
        // binding for annotation - adding annotation for bus stosp
        busStops
            .asObservable()
            .map { busStops -> [BusStopAnnotation] in
                return busStops.map({ (busStop) -> BusStopAnnotation in
                    return BusStopAnnotation(title: busStop.name, busStopCode: busStop.busStopCode, coordinate: busStop.coordinate)
                })
            }
            .subscribe(onNext: { [weak self] annotations in
                self?.mapView.addAnnotations(annotations)
            })
            .addDisposableTo(disposeBag)
        
        // binding for destinationBusStopAnnotaion = adding annotation for destination busStop. 
        destinationAnnotationManager
            .asObservable()
            .subscribe(onNext: {[weak self] destinationAnnotationManager in
                let previousAnnotation = destinationAnnotationManager.previousDestionationAnnotation
                let currentAnnotation = destinationAnnotationManager.currentDestionationAnnotation
                switch (previousAnnotation,
                        currentAnnotation){
                case (nil, nil):
                    return
                case (nil, _):
                    let currentBusStopAnnotation = self!.busStopAnnotationFromDestionationAnnotation(currentAnnotation!)
                    self?.mapView.removeAnnotation(currentBusStopAnnotation)
                    self?.mapView.addAnnotation(currentAnnotation!)
                case (_, nil):
                    self?.mapView.removeAnnotation(previousAnnotation!)
                    let busStopAnnotation = self!.busStopAnnotationFromDestionationAnnotation(previousAnnotation!)
                    self?.mapView.addAnnotation(busStopAnnotation)
                case (_, _):
                    self?.mapView.removeAnnotation(previousAnnotation!)
                    self?.mapView.addAnnotation(currentAnnotation!)
                    let busStopAnnotaitonToBeInserted = self!.busStopAnnotationFromDestionationAnnotation(previousAnnotation!)
                    self?.mapView.addAnnotation(busStopAnnotaitonToBeInserted)
                    let busStopAnnotaitonToBeDeleted = self!.busStopAnnotationFromDestionationAnnotation(currentAnnotation!)
                     self?.mapView.removeAnnotation(busStopAnnotaitonToBeDeleted)
                }
            })
            .addDisposableTo(disposeBag)

        // use a button to set
    }
    
    func busStopAnnotationFromDestionationAnnotation(_ destionationAnnotation : DestinationBusStopAnnotation) -> BusStopAnnotation{
        for annotion in mapView.annotations{
            if let busStopAnnotation = annotion as? BusStopAnnotation{
                if busStopAnnotation.subtitle == destionationAnnotation.subtitle{
                    return busStopAnnotation
                }
            }
            
        }
        return BusStopAnnotation(title: destionationAnnotation.title ?? "", busStopCode: destionationAnnotation.busStopCode , coordinate: (destionationAnnotation.coordinate.latitude, destionationAnnotation.coordinate.longitude))
    }
}


// MARK: - NotificationCentre Functions
extension MapViewController{
    fileprivate func addNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow , object: nil)
    }
    
    fileprivate func removeNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    func keyboardWillShow(notification : NSNotification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            addAnimation(animationTime : 0.5, layoutChanges: { [weak self] in
                self?.whiteBoxBottomContraint.constant = keyboardSize.height + 5
                self?.view.layoutIfNeeded()
                
            })
            
        }
    }
}

// MARK: - Gesture Functions
extension MapViewController{
    fileprivate func addTapToDismissEditingGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToEndEditing))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func tapToEndEditing(){
        if destinationTextfield.isFirstResponder {
            addAnimation(animationTime: 0.4, layoutChanges: { [weak self] in
                self?.whiteBoxBottomContraint.constant = 30
                self?.view.layoutIfNeeded()
                
            })
            view.endEditing(true)
        }
    }
}

//MARK: - UIPickerDelegate and UIPickerDataSource
extension MapViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return destinationsDescrip.value.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return destinationsDescrip.value[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        destinationTextfield.text = destinationsDescrip.value[row]
    }
    
}


//MAR: - Map & CoreLocation Functions
extension MapViewController : MKMapViewDelegate {
    func initializingMap(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.delegate = self
        mapView.showsUserLocation = (CLLocationManager.authorizationStatus() == .authorizedAlways)
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = Colors.pink
        polylineRenderer.lineWidth = 2
        return polylineRenderer
    }
    
    // setting up pinView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? BusStopAnnotation {
            let identifier = Identifiers.kNormalBusStopAnnotationView
            var view : BusStopPinView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? BusStopPinView{
                dequeuedView.annotation = annotation
                view = dequeuedView
            }else{
                view = BusStopPinView(annotation: annotation, reuseIdentifier: identifier)
            }
            
            return view
        }else if let annotation = annotation as? DestinationBusStopAnnotation{
            let identifier = Identifiers.kDestinationBusStopAnnotationView
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
            guard let annotation = view.annotation as? BusStopAnnotation else{
                return
            }
             let destinationBusStopAnnotation = DestinationBusStopAnnotation(title: (annotation.title ?? "")!, busStopCode: (annotation.subtitle ?? "")!, coordinate: (annotation.coordinate.latitude, annotation.coordinate.longitude))
            destinationAnnotationManager.value.update(destinationBusStopAnnotation)
        }
        
        if view is DestinationBusStopPinView {
            destinationAnnotationManager.value.remove()
        }
    }
}

//MARK: GeoFencing - CLLocationManagerDelegate
extension MapViewController : CLLocationManagerDelegate{
    func monitoringRegion(_ destinationBusStop : DestinationBusStopAnnotation)->CLCircularRegion{
        let region = CLCircularRegion(center: destinationBusStop.coordinate, radius: notificationRadius, identifier: Identifiers.kMonitoringRegion)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        return region
    }
    
    func startMonitoring(){
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self){
            Utility.showAlert(in: self, title: Strings.kError, message: Strings.kGeoFencingFeatureNotAvailable)
            return
        }
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            Utility.showAlert(in: self, title: Strings.kWarning, message: Strings.kAllowLocationAccess)
        }
        
        if let destinationBusStop = destinationAnnotationManager.value.currentDestionationAnnotation{
            let region = monitoringRegion(destinationBusStop)
            locationManager.startMonitoring(for: region)
            
        }
    }
    
    func stopMonitoring() {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == Identifiers.kMonitoringRegion else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
    func addNotification(){
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = Strings.kAttention
        notificationContent.body = Strings.kAlmostArrived
        notificationContent.sound = UNNotificationSound.default()
        let timeScheduleNotification = UNTimeIntervalNotificationTrigger(timeInterval: 0.0, repeats: false)
    
        let notificationRequest = UNNotificationRequest(identifier: Identifiers.kLocationNotification, content: notificationContent, trigger: timeScheduleNotification)
        UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: nil)
    }
    
    func removeNotification(){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Identifiers.kLocationNotification])
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        addNotification()
    }
}






