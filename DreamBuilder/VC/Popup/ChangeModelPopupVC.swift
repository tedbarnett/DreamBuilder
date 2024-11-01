//
//  ChangeModelPopupVC.swift
//  DreamBuilder
//
//  Created by iMac on 22/10/24.
//

import UIKit
import ARKit

class ChangeModelPopupVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnClose: UIButton!
    
    // MARK: - Variables
    var arrPergola: [PergolaModel] = []
    var pergolaModelDidSelected: ((PergolaModel)->())?
    
    // MARK: - Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PergolaModelCell", bundle: nil), forCellReuseIdentifier: "PergolaModelCell")
        
        let modern1 = PergolaModel(url: Bundle.main.url(forResource: "PERGOLA_12x20x9_Y-UP", withExtension: "usdz")!,
                                  name: "2 post",
                                  description: "6\" steel beams, louvered sunscreen",
                                  scale: SCNVector3(x: 0.09, y: 0.09, z: 0.09),
                                  minScale: SCNVector3(x: 0.008, y: 0.008, z: 0.008),
                                  eulerAngles: SCNVector3(x: -1.6, y: 0, z: 0),
                                  image: .pivot6, baseColor: .black, louverColor: .gray)
        
        let modern2 = PergolaModel(url: Bundle.main.url(forResource: "PERGOLA_12x20x9_Y-UP", withExtension: "usdz")!,
                                  name: "4 post",
                                  description: "6\" steel beams, louvered sunscreen",
                                  scale: SCNVector3(x: 0.09, y: 0.09, z: 0.09),
                                  minScale: SCNVector3(x: 0.008, y: 0.008, z: 0.008),
                                  eulerAngles: SCNVector3(x: -1.6, y: 0, z: 0),
                                  image: .pivot6, baseColor: .black, louverColor: .gray)
        
        arrPergola.append(contentsOf: [modern1, modern2])
    }

    // MARK: - Actions
    @IBAction func btnCloseAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ChangeModelPopupVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPergola.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PergolaModelCell", for: indexPath) as! PergolaModelCell
        cell.lblTitle.text = arrPergola[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            self.pergolaModelDidSelected?(self.arrPergola[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
