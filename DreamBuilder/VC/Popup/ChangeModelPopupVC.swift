//
//  ChangeModelPopupVC.swift
//  DreamBuilder
//
//  Created by iMac on 22/10/24.
//

import UIKit

class ChangeModelPopupVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnClose: UIButton!
    
    // MARK: - Variables
    var arrPergoals: [PergolaModel] = []
    var pergolaModelDidSelected: ((PergolaModel)->())?
    
    // MARK: - Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PergolaModelCell", bundle: nil), forCellReuseIdentifier: "PergolaModelCell")
    }

    // MARK: - Actions
    @IBAction func btnCloseAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ChangeModelPopupVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPergoals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PergolaModelCell", for: indexPath) as! PergolaModelCell
        cell.lblTitle.text = arrPergoals[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            self.pergolaModelDidSelected?(self.arrPergoals[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
