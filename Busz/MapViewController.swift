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
import VHBoomMenuButton
import RealmSwift

class MapViewController: UIViewController {
    
    // MARK: - Properties
    fileprivate let normalBusStops = Variable<[BusStop]>([])
    fileprivate let destinationsDescrip = Variable<[String]>([])
    fileprivate let destinationAnnotationManager = Variable<DestinationAnnotationManager>(DestinationAnnotationManager())
    fileprivate let pastDestination = Variable<DestinationBusStopAnnotation?>(nil)
    fileprivate let alarmBusStopVas = Variable<AlarmBusStopAnnotation?>(nil)
    fileprivate let chosenBusStopForTimeArrivalCheck = Variable<BusStopAnnotation?>(nil)
    
    let disposeBag = DisposeBag()
    let fileReader = FileReader.share
    let apiClient = APIClient.share
    fileprivate let locationManager = CLLocationManager()
    
    //input
    let chosenBus = Variable<Bus?>(nil)
    fileprivate let updatedBus = Variable<Bus?>(nil)
    fileprivate let notificationRadius : CLLocationDegrees = 100
    fileprivate let estimatedTime = Variable<String?>(nil)
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var destinationPicker: UIPickerView!
    @IBOutlet weak var whiteBox: UIView!
    @IBOutlet weak var destinationTextfield: UITextField!
    @IBOutlet weak var whiteBoxBottomContraint: NSLayoutConstraint!
    
    @IBOutlet weak var setAlarmButton: UIButton!
    @IBOutlet weak var turnOffAlarmButton: UIButton!
    
    // MARK: - Life Cycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData(routeNumber: Strings.kRouteOne)
        setupUI()
        addNotifications()
        addTapToDismissEditingGesture()
        initializingMap()
        sequentialBinding()
        
    }
    
    deinit {
        removeNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if chosenBus.value != nil{
//            self.whiteBox.isHidden = false
//            self.turnOffAlarmButton.isHidden = true
//        }
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
    fileprivate func loadData(routeNumber : String){
      
        let observable = chosenBus
            .asObservable()
            .filter{return ($0 != nil)}
        
        observable
            .subscribe(onNext: { [weak self] bus in
                self?.destinationAnnotationManager.value.currentDestionationAnnotation = nil
                self?.destinationAnnotationManager.value.previousDestionationAnnotation = nil
                self?.turnOffAlarmButton.isHidden = true
                self?.navigationItem.title =  "Bus \(bus!.busNumber) - Route \(routeNumber)"
                self?.fileReader.route(number: routeNumber, bus: bus!)
                    .bind(to: self!.updatedBus)
                    .addDisposableTo(self!.disposeBag)
                
                // read destination from
                self?.pastDestination.value = Utility.readDestionationAnnotation(busNumer: bus!.busNumber)
                self?.alarmBusStopVas.value = Utility.readAlarmBusStopAnnotation(busNumer: bus!.busNumber)
                print("read alarm bus value")
            })
            .addDisposableTo(disposeBag)
        
        observable.map { _ -> Bool in
            return true
        }
        .subscribe(onNext: { [weak self] _ in
            self?.bindingData()
            self?.bindingUI()
            self?.addAlarmBusAnnotation()
            
        })
        .addDisposableTo(disposeBag)
    }
    
    fileprivate func addAlarmBusAnnotation(){
        
        // binding for annotation - adding annotation for bus stosp
        let normalBusStopsObservable = normalBusStops
            .asObservable()
            .map { busStops -> [BusStopAnnotation] in
                return busStops.map({ (busStop) -> BusStopAnnotation in
                    return BusStopAnnotation(title: busStop.name, busStopCode: busStop.busStopCode, coordinate: busStop.coordinate)
                })
        }
        
        normalBusStopsObservable
            .subscribe(onNext: { [weak self] annotations in
                print("remove all annotaitons")
                self?.removeAllAnnotations()
                // neccessary to down cast again.
                if let alarmBusStopAnnotaiton = self?.alarmBusStopVas.value{
                    for annotation in annotations {
                        if alarmBusStopAnnotaiton.busStopCode == annotation.busStopCode{
                            continue
                        }else{
                            self?.mapView.addAnnotation(annotation)
                        }
                    }
                }else{
                    self?.mapView.addAnnotations(annotations)
                }
                
                self?.destinationAnnotationManager.value.currentDestionationAnnotation = self?.pastDestination.value
                
            })
            .addDisposableTo(disposeBag)
        
        let finishedPlacingNormalAnnotationsObservable = normalBusStopsObservable
            .map {  _ -> Bool in
                return true
            }
            .startWith(false)
        

        
        finishedPlacingNormalAnnotationsObservable
            .asObservable()
            .subscribe(onNext: { [weak self] finishPlacing in
                if finishPlacing == true {
                    self?.alarmBusStopVas
                        .asObservable()
                        .filter{return $0 != nil}
                        .subscribe(onNext: { [weak self] alarmDestinationAnnotatin in
                            print("add alarmannotaion")
                            for annotation in self!.mapView.annotations{
                                if let annotation = annotation as? BusStopAnnotation{
                                    if annotation.busStopCode == alarmDestinationAnnotatin?.busStopCode{
                                        self?.mapView.removeAnnotation(annotation)
                                        break
                                    }
                                }else if let annotation = annotation as? DestinationBusStopAnnotation{
                                    self?.mapView.removeAnnotation(annotation)
                                }
                            }
                            self?.mapView.addAnnotation(alarmDestinationAnnotatin!)
                        })
                        .addDisposableTo(self!.disposeBag)
                }
            })
            .addDisposableTo(disposeBag)
        
        // adding polyline for routes
        finishedPlacingNormalAnnotationsObservable
            .asObservable()
            .subscribe(onNext: { [weak self] (finishedPlaceingNormalAnnotaitons) in
                self?.updatedBus
                    .asObservable()
                    .filter{return ($0 != nil)}
                    .map { bus -> [CLLocationCoordinate2D] in
                        return bus!.routes.map({ (altitude, longtitude) -> CLLocationCoordinate2D in
                            return CLLocationCoordinate2D(latitude: altitude, longitude: longtitude)
                        })
                    }
                    .subscribe(onNext: { [weak self] coordinates in
                        var coords = coordinates
                        let polyline = MKPolyline(coordinates: &coords, count: coords.count)
                        self?.mapView.add(polyline)
                    })
                    .addDisposableTo(self!.disposeBag)
            })
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
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000)
        mapView.setRegion(region, animated: true)
    }
    
    fileprivate func removeAllAnnotations(){
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
    }
    fileprivate func loadDestination(){
        
    }
    
}

//MARK: - RxSwift and Bidning
extension MapViewController{
    
    fileprivate func sequentialBinding(){
        chosenBusRelatedBinding()
    }
    
    
    fileprivate func chosenBusRelatedBinding(){
        // these bindings are in natural sequential to loadData()
        let chosenBusObservable = chosenBus
            .asObservable()
        
        chosenBusObservable
            .subscribe(onNext: {[weak self] bus in
                if let bus = bus{
                    self?.navigationItem.title =  "Bus \(bus.busNumber) - Route \(Strings.kRouteOne)"
                    self?.whiteBox.isHidden = false
                    self?.navigationItem.rightBarButtonItem = self?.getRightBarButton()
                    
                }else{
                    self?.whiteBox.isHidden = true
                    self?.navigationItem.title = Strings.kChooseABus
                    self?.navigationItem.rightBarButtonItem = nil
                }
            })
            .addDisposableTo(disposeBag)
        
        chosenBusObservable
            .map{ _ in return true}
            .subscribe(onNext: { [weak self] status  in
                if status == true {
                    self?.alarmBusStopVas
                        .asObservable()
                        .filter{return ($0 != nil)}
                        .subscribe(onNext: { alarmBusStopAnnotation in
                            if alarmBusStopAnnotation != nil{
                                self?.whiteBox.isHidden = true
                                self?.turnOffAlarmButton.isHidden = false
                            }else{
                                self?.whiteBox.isHidden = false
                                self?.turnOffAlarmButton.isHidden = true
                                
                            }
                            
                            
                        })
                        .addDisposableTo(self!.disposeBag)
                }
            })
            .addDisposableTo(disposeBag)
        
        
        updatedBus
            .asObservable()
            .filter{ return ($0 != nil) }
            .map { [weak self] bus -> Void in
                if !(bus!.routes.count > 0) {
                    Utility.showAlert(in: self!, title: "This bus has no second route")
                    self?.navigationItem.title =  "Bus \(bus!.busNumber) - Route \(Strings.kRouteOne)"
                }
            }
            .subscribe()
            .addDisposableTo(disposeBag)
        
        let busObservable = updatedBus
            .asObservable()
            .filter{ return ($0 != nil && $0!.routes.count > 0) }
        
        
        
        busObservable
            .map { bus -> [String] in
                return bus!.busStops.normalStops.map({ (busStop) -> String in
                    return busStop.name
                })
            }
            .subscribe(onNext: { [weak self] strings in
                self?.destinationsDescrip.value = strings
                self?.destinationTextfield.text = ""
                self?.destinationPicker.reloadAllComponents()
            })
            .addDisposableTo(disposeBag)
        
        busObservable
            .map { bus -> [BusStop] in
                return bus!.busStops.normalStops
            }
            .bind(to: normalBusStops)
            .addDisposableTo(disposeBag)
        
//        pastDestination
//            .asObservable()
//            .filter{return $0 != nil}
//            .subscribe(onNext: { [weak self] destinationBusStopAnnotation in
//                print("setting destinatin bus stop")
//                
//            })
//            .addDisposableTo(disposeBag)
        
    }
    
    
    fileprivate func bindingData(){
        
    
        
        let estimatedTimeObservable =  estimatedTime
            .asObservable()
            .skip(1)
        let chosenBusForTimeArrivalCheckObservable = chosenBusStopForTimeArrivalCheck
            .asObservable()
            .filter{return ($0 != nil)}
        
        Observable.zip(estimatedTimeObservable, chosenBusForTimeArrivalCheckObservable) { [weak self](estimatedTimeMessage, chosenBusStopAnnotation) -> Void in
            if let estimatedTimeMessage = estimatedTimeMessage{
                Utility.showAlert(in: self!, title: estimatedTimeMessage, message: Strings.kAddToMonitor, addAction: {
                    Utility.saveBusForArrival(busNumber: (self!.chosenBus.value?.busNumber)!, busStopCode: (chosenBusStopAnnotation?.subtitle)!, busStopName: (chosenBusStopAnnotation?.title)!)
                })
            }else{
                Utility.showAlert(in: self!, title: Strings.kArrivalDataNotAvailable, message: Strings.kTryAgainlater)
            }
        }
            .subscribe()
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
                    let selectedBusStop = self!.normalBusStops.value[index]
                    let coordinateTuple = selectedBusStop.coordinate
                    let destinationBusStopAnnotation = DestinationBusStopAnnotation(title: selectedBusStop.name, busStopCode: selectedBusStop.busStopCode, coordinate: coordinateTuple)
                    self?.destinationAnnotationManager.value.update(destinationBusStopAnnotation)
                    
                    self?.zoomToLocation(with: CLLocationCoordinate2D(latitude: coordinateTuple.0, longitude: coordinateTuple.1))
                }
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
        
        destinationAnnotationManager
            .asObservable()
            .map { (manager) -> DestinationBusStopAnnotation? in
                return manager.currentDestionationAnnotation
            }
            .subscribe(onNext: { [weak self] destinationAnnotaiton in
                self?.destinationTextfield.text = destinationAnnotaiton?.title ?? ""
            })
            .addDisposableTo(disposeBag)
        
        destinationAnnotationManager
            .asObservable()
            .map { manager -> Bool in
                if manager.currentDestionationAnnotation == nil {
                    return false

                }else{
                    return true
                }
            }
            .subscribe(onNext: { [weak self] isEnable in
                self?.setAlarmButton.isEnabled = isEnable
                if isEnable {
                    self?.setAlarmButton.setTitleColor(.black, for: .normal)
                }else{
                    self?.setAlarmButton.setTitleColor(.lightGray, for: .normal)
                }
            })
            .addDisposableTo(disposeBag)

        // use a button to set
        
        turnOffAlarmButton.rx.controlEvent(.touchUpInside)
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.stopMonitoring()
                self?.updateAlarmBusStopAnnotationAfterStoppingMonitoring()
            })
            .addDisposableTo(disposeBag)
        
        setAlarmButton.rx.controlEvent(.touchUpInside)
            .asObservable()
            .subscribe(onNext: {[weak self] _ in
                if let destinationAnnotation = self?.destinationAnnotationManager.value.currentDestionationAnnotation{
                    let success = Utility.saveBusForAlarmBusStop(busNumber: (self?.chosenBus.value?.busNumber)!,
                                                   busStopCode: destinationAnnotation.busStopCode,
                                                   busStopName: destinationAnnotation.title!,
                                                   latitude: destinationAnnotation.coordinate.latitude,
                                                   longtitude: destinationAnnotation.coordinate.longitude,
                                                    viewController :self!)
                    if success {
                        self?.alarmBusStopVas.value = Utility.readAlarmBusStopAnnotation(busNumer: (self?.chosenBus.value?.busNumber)!)
                        Utility.showAlert(in: self!, title: "Bus \((self?.chosenBus.value?.busNumber)!)", message: "Destionation: \(destinationAnnotation.title!)", okAction: {
                             self?.startMonitoring()
                            print("start monnitoring")
                        })
                       
                    }
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    func updateAlarmBusStopAnnotationAfterStoppingMonitoring(){
        for annotaion in mapView.annotations{
            if let annotaion = annotaion as? AlarmBusStopAnnotation{
                let busStopAnnotation = busStopAnnotationFromAlarmBusStopAnnotation(annotaion)
                mapView.removeAnnotation(annotaion)
                mapView.addAnnotation(busStopAnnotation)
            }
        }
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
    
    func busStopAnnotationFromAlarmBusStopAnnotation(_ alarmBusStopAnnotation : AlarmBusStopAnnotation) -> BusStopAnnotation {
        for annotion in mapView.annotations{
            if let busStopAnnotation = annotion as? BusStopAnnotation{
                if busStopAnnotation.subtitle == alarmBusStopAnnotation.subtitle{
                    return busStopAnnotation
                }
            }
        }
        return BusStopAnnotation(title: alarmBusStopAnnotation.title ?? "", busStopCode: alarmBusStopAnnotation.busStopCode , coordinate: (alarmBusStopAnnotation.coordinate.latitude, alarmBusStopAnnotation.coordinate.longitude))
    }
}


// MARK: - NotificationCentre Functions
extension MapViewController{
    fileprivate func addNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func removeNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func keyboardWillShow(notification : NSNotification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            addAnimation(animationTime : 0.5, layoutChanges: { [weak self] in
                self?.whiteBoxBottomContraint.constant = keyboardSize.height + 5 - 49
                self?.view.layoutIfNeeded()
                
            })
            
        }
    }
    func keyboardWillHide(notification : NSNotification){
        addAnimation(animationTime : 0.5, layoutChanges: { [weak self] in
            self?.whiteBoxBottomContraint.constant = 40
            self?.view.layoutIfNeeded()
            
        })
    }
}

// MARK: - Gesture Functions
extension MapViewController{
    fileprivate func addTapToDismissEditingGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToEndEditing))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func tapToEndEditing(){
        if destinationTextfield.isFirstResponder {
            addAnimation(animationTime: 0.4, layoutChanges: { [weak self] in
                self?.whiteBoxBottomContraint.constant = 40
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
        }else if let annotation = annotation as? AlarmBusStopAnnotation{
            let identifier = Identifiers.kAlarmBusStopAnnotationView
            var view : AlarmBusStopPinView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? AlarmBusStopPinView{
                dequeuedView.annotation = annotation
                view = dequeuedView
            }else{
                view = AlarmBusStopPinView(annotation: annotation, reuseIdentifier: identifier)
            }
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
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
        }else{
            checkBusArrivingTime(view)
        }
    }
    
    func checkBusArrivingTime(_ view : MKAnnotationView){
        if let annotation = view.annotation as? BusStopAnnotation{
            guard let busStopCode = annotation.subtitle, let busStopName = annotation.title else {
                Utility.showAlert(in: self, title: Strings.kArrivalDataNotAvailable, message: Strings.kTryAgainlater)
                return
            }
            let busNumber = updatedBus.value!.busNumber
            apiClient.getBusArrivalTime(busStopCode: busStopCode, serviceNo: busNumber, busStopName: busStopName)
                .asObservable()
                .observeOn(MainScheduler.instance)
                .bind(to: estimatedTime)
                .addDisposableTo(disposeBag)
            
            chosenBusStopForTimeArrivalCheck.value = annotation
        }
    }
}

//MARK: GeoFencing - CLLocationManagerDelegate
extension MapViewController : CLLocationManagerDelegate{
    func monitoringRegion(_ destinationBusStop : DestinationBusStopAnnotation)->CLCircularRegion{
        let region = CLCircularRegion(center: destinationBusStop.coordinate, radius: notificationRadius, identifier: (chosenBus.value?.busNumber)!)
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
            locationManager.startUpdatingLocation()
            locationManager.startMonitoring(for: region)
            print("the number of monitored regions = \(locationManager.monitoredRegions.count)")
        }
        
    }
    
    func stopMonitoring() {
         print("the number of monitored regions = \(locationManager.monitoredRegions.count)")
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == (chosenBus.value?.busNumber)! else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
        let success = Utility.archiveBusForAlarmBusStop()
        if success {
            self.whiteBox.isHidden = false
            self.turnOffAlarmButton.isHidden = true
        }
    }
    
    func removeNotification(){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Identifiers.kLocationNotification])
    }

//    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        addNotification()
//        stopMonitoring()
//    }
}


//MARK: Configured right barbutton
extension MapViewController{
    func getRightBarButton() -> UIBarButtonItem {
        let bmb = BoomMenuButton.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 60))
        bmb.buttonEnum = .ham
        bmb.piecePlaceEnum =  .ham_2
        bmb.buttonPlaceEnum = .ham_2
        
        for i in 0..<2{
            let builder = HamButtonBuilder.init()
            builder.pieceColor = Colors.mediumPink
            builder.normalColor = Colors.mediumPink
            if i == 0 {
                builder.normalText = "Route 1"
            }else{
                builder.normalText = "Route 2"
            }
            builder.clickedClosure = {[weak self] (index: Int) -> Void in
                if index == 0 {
                    self?.loadData(routeNumber: Strings.kRouteOne)
                }
                
                if index == 1{
                    self?.loadData(routeNumber: Strings.kRouteTwo)
                }
            }
            builder.width = 150
            builder.height = 60
            builder.shadowPathRect = CGRect.init(x: 2, y: 2, width: 150, height: 60)
            builder.textAlignment = NSTextAlignment.center
            builder.textFrame = CGRect.init(x: 0, y: 0, width: 150, height: 60)
            bmb.addBuilder(builder)
        }
        bmb.hasBackground = false
        return UIBarButtonItem(customView: bmb)
    }

}





