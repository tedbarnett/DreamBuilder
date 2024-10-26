//
//  AdjustAnimationPopupVC.swift
//  DreamBuilder
//
//  Created by iMac on 07/10/24.
//

// changed on 22/10/24 3:25 PM

import UIKit

class AdjustAnimationPopupVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMinimumValue: UILabel!
    @IBOutlet weak var lblMaximumValue: UILabel!
    @IBOutlet weak var lightSlider: CustomSlider!
    
    // MARK: - Variables
    var titleStr: String = ""
    var value: Float = 0
    var minimumValue: Float = 0
    var maximumValue: Float = 100
    var sliderValueDidChange: ((Float)->())?
    
    // MARK: - Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Function
    func setupUI() {
        lightSlider.value = value
        lightSlider.minimumValue = 0
        lightSlider.maximumValue = 1
        
        lblTitle.text = titleStr
        lblMinimumValue.text = "\(Int(minimumValue))"
        lblMaximumValue.text = "\(Int(maximumValue))"
    }
    
    // MARK: - Action
    @IBAction func lightSliderChanged(_ sender: CustomSlider) {
        value = lightSlider.value
        sliderValueDidChange?(value)
    }
    
    @IBAction func btnCloseAction(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.sliderValueDidChange?(self.value)
        }
    }
}
