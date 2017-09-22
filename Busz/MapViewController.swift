//
//  MapViewController.swift
//  Busz
//
//  Created by Hairui Lin on 22/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    // MARK : - Properties
    
    
    // IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var destinationPicker: UIPickerView!
    @IBOutlet weak var whiteBox: UIView!
    
    
    // MARK : - Life Cycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK : IBActions. 
    @IBAction func setAlarmButtonPressed(_ sender: UIButton) {
    }
    
}
