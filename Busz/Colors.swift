//
//  Colors.swift
//  Busz
//
//  Created by Hairui Lin on 22/9/17.
//  Copyright © 2017 Hairui Lin. All rights reserved.
//

import Foundation
import UIKit
struct Colors {
    static let heavyPink = UIColor(r: 255.0, g: 140.0, b: 148.0, alpha: 1)
    static let pink = UIColor(r: 255, g: 170, b: 166, alpha: 1)
    static let yellow = UIColor(r: 255, g: 211, b: 181, alpha: 1)
    static let lightGreen = UIColor(r: 220, g: 237, b: 194, alpha: 1)
    static let heavyGreen = UIColor(r: 168, g: 230, b: 206, alpha: 1)
    
    static let mediumPink = UIColor(r: 255, g: 96, b: 119, alpha: 1)
    static let mediumPuprple = UIColor(r: 207, g: 97, b: 131, alpha: 1)
    static let heavyPurple = UIColor(r: 115, g: 87, b: 127, alpha: 1)
    static let lightYellow = UIColor(r: 248, g: 177, b: 149, alpha: 1)
    static let heavyBlue = UIColor(r: 24, g: 59, b: 89, alpha: 1)
}


extension UIColor {
    convenience init(r: CGFloat, g: CGFloat , b: CGFloat , alpha: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: alpha)
    }
}
