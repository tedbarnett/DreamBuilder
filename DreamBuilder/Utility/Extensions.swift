//
//  Extensions.swift
//  DreamBuilder
//
//  Created by iMac on 03/10/24.
//

import Foundation
import ARKit

// MARK: - UIViewController
extension UIViewController {
    
    public func checkCameraPermission(completion: @escaping ((Bool) -> Void)) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        case .authorized:
            completion(true)
        case .restricted, .denied:
            completion(false)
        @unknown default:
            completion(false)
            break
        }
    }
    
    public func showCameraPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "Please enable camera access in Settings to use this feature.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    public func showAlert(title: String? = "Oops!", message: String? = "Something went wrong.", isBtnHidden: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if isBtnHidden == false {
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
        }
        
        present(alert, animated: true)
    }
    
    public func showUnsupportedPlatformAlert(action: @escaping ()->()) {
        let message = "This app requires world tracking. World tracking is only available on iOS devices with A9 processor or newer. Please quit the application."
        let alert = UIAlertController(title: "Unsupported Platform", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            action()
        }
        
        alert.addAction(ok)
        present(alert, animated: true)
    }
}

// MARK: - ARSCNView
extension ARSCNView {
    
    // Show Move iPhone to start animation
    public func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView(frame: self.bounds)
        coachingOverlay.autoresizingMask = [
            .flexibleWidth, .flexibleHeight
        ]
        
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.session = self.session
        coachingOverlay.setActive(true, animated: true)
        self.addSubview(coachingOverlay)
    }
}

// MARK: - SCNVector3
extension SCNVector3 {
    func distance(to vector: SCNVector3) -> Float {
        return sqrt(pow(vector.x - self.x, 2) + pow(vector.y - self.y, 2) + pow(vector.z - self.z, 2))
    }
}

// MARK: - CGPoint
extension CGPoint {
    /// Extracts the screen space point from a vector returned by SCNView.projectPoint(_:).
    init(_ vector: SCNVector3) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }

    /// Returns the length of a point when considered as a vector. (Used with gesture recognizers.)
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
}
