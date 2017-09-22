//
//  ViewController.swift
//  Busz
//
//  Created by Hairui Lin on 22/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    //private let apiClient = APIClient.share
    private let fileReader = FileReader.share
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let file = Bundle.main.path(forResource: "1N", ofType: "json") else{
            print("cannot read anything")
            return
        }
    }
}

