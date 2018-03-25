//
//  UIColor+Ext.swift
//  Phonero
//
//  Created by Simen Lie on 25.03.2018.
//  Copyright © 2018 Liite. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255

        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}
