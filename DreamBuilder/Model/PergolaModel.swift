//
//  PergolaModel.swift
//  DreamBuilder
//
//  Created by iMac on 17/10/24.
//

import Foundation
import ARKit

// MARK: - ModelInfo
struct PergolaModel {
    
    // MARK: - Properties
    let url: URL
    let description: String
    let scale: SCNVector3
    let minScale: SCNVector3
    let eulerAngles: SCNVector3
}