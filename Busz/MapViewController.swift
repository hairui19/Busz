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

    // MARK: - Properties
    fileprivate let dummyData = ["1", "2", "3", "4"]
    fileprivate let disposeBag = DisposeBag()
    
    //input
    var bus : Bus!
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var destinationPicker: UIPickerView!
    @IBOutlet weak var whiteBox: UIView!
    @IBOutlet weak var destinationTextfield: UITextField!
    @IBOutlet weak var whiteBoxBottomContraint: NSLayoutConstraint!
    
    
    // MARK: - Life Cycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addNotifications()
        addTapToDismissEditingGesture()
        bindingUItoRx()
    }
    
    // MARK: IBActions.
    @IBAction func setAlarmButtonPressed(_ sender: UIButton) {
    }
    
    deinit {
        removeNotifications()
    }
    
    
    // MARK: - Animation Function
    fileprivate func addAnimation(animationTime : TimeInterval, layoutChanges : @escaping ()->()){
        UIView.animate(withDuration: animationTime) {
            layoutChanges()
        }
    }

}

//MARK: - RxSwift and Bidning
extension MapViewController{
    func bindingUItoRx(){
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
        
    }
    
    func getRowForSearchText(searchText : String) -> Int{
        var index = 0
        for data in dummyData{
            if data.lowercased().range(of: searchText.lowercased()) != nil {
                return index
            }else{
                index += 1
            }
        }
        return -1
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
        return dummyData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dummyData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        destinationTextfield.text = dummyData[row]
    }

}






