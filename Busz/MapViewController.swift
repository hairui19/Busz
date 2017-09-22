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

class MapViewController: UIViewController {

    // MARK : - Properties
    fileprivate let dummyData = ["1", "2", "3", "4"]
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var destinationPicker: UIPickerView!
    @IBOutlet weak var whiteBox: UIView!
    @IBOutlet weak var destinationTextfield: UITextField!
    @IBOutlet weak var whiteBoxBottomContraint: NSLayoutConstraint!
    
    
    // MARK : - Life Cycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addNotifications()
        addTapToDismissEditingGesture()
    }
    
    // MARK : IBActions. 
    @IBAction func setAlarmButtonPressed(_ sender: UIButton) {
    }
    
    deinit {
        removeNotifications()
    }
}


// MARK : - NotificationCentre Functions
extension MapViewController{
    fileprivate func addNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow , object: nil)
    }
    
    fileprivate func removeNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    func keyboardWillShow(notification : NSNotification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            whiteBoxBottomContraint.constant = keyboardSize.height + 3
        }
    }
}

// MARK : - Gesture Functions
extension MapViewController{
    fileprivate func addTapToDismissEditingGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToEndEditing))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func tapToEndEditing(){
        if destinationTextfield.isFirstResponder {
            whiteBoxBottomContraint.constant = 30
            view.endEditing(true)
        }
    }
}

//MARK : - UIPickerDelegate and UIPickerDataSource
extension MapViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dummyData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dummyData[row]
    }

}






