//
//  AdjustLightPopupVC.swift
//  DreamBuilder
//
//  Created by iMac on 23/10/24.
//

import UIKit

class AdjustLightPopupVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var switchLightOnOff: UISwitch!
    
    // MARK: - Variables
    var titleStr = "Lights On/Off"
    var isLightOn: Bool = false
    var lightStateDidUpdated: ((Bool)->())?
    
    // MARK: - Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = titleStr
        switchLightOnOff.isOn = isLightOn
    }

    // MARK: - Actions
    @IBAction func btnCloseAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction func switchLightOnOffAction(_ sender: UISwitch) {
        lightStateDidUpdated?(sender.isOn)
    }
}
