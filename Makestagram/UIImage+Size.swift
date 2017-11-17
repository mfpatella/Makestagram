//
//  UIImage+Size.swift
//  Makestagram
//
//  Created by Matthew Patella on 10/17/17.
//  Copyright © 2017 Matthew Patella. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    var aspectHeight: CGFloat {
        let heightRatio = size.height / 736
        let widthRatio = size.width / 414
        let aspectRatio = fmax(heightRatio, widthRatio)
        
        return size.height / aspectRatio
    }
}
