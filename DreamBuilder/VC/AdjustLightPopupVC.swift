//
//  AdjustLightPopupVC.swift
//  DreamBuilder
//
//  Created by iMac on 07/10/24.
//

import UIKit

class AdjustLightPopupVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lightSlider: CustomSlider!
    
    // MARK: - Variable
    var light: Float = 0.5
    var lightSliderValueDidChange: ((Float)->())?
    
    // MARK: - Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Function
    func setupUI() {
        lightSlider.value = light
        lightSlider.minimumValue = 0
        lightSlider.maximumValue = 1
    }
    
    // MARK: - Action
    @IBAction func lightSliderChanged(_ sender: CustomSlider) {
        light = lightSlider.value
        lightSliderValueDidChange?(light)
    }
    
    @IBAction func btnCloseAction(_ sender: UIButton) {
        lightSliderValueDidChange?(light)
        self.dismiss(animated: true)
    }
}
