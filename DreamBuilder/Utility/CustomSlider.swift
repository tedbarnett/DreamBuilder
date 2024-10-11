//
//  CustomSlider.swift
//  DreamBuilder
//
//  Created by iMac on 07/10/24.
//

import UIKit

class CustomSlider: UISlider {
    
    // MARK: - IBInspectable
    @IBInspectable var trackHeight: CGFloat = 10
    
    // MARK: - Method
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: bounds.origin, size: CGSizeMake(bounds.width, trackHeight))
    }

}
