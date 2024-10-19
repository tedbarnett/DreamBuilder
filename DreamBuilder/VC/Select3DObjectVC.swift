//
//  Select3DObjectVC.swift
//  DreamBuilder
//
//  Created by iMac on 07/10/24.
//

import UIKit
import ARKit

class Select3DObjectVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnPlace3DObject: UIButton!
    
    // MARK: - Variable
    var arrPergolaModel: [PergolaModel] = []
    var selectedPergolaModel: PergolaModel?
    
    // MARK: - Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        loadModels()
        setupUI()
    }
    
    // MARK: - Action
    @IBAction func btnPlace3DObjectAction(_ sender: UIButton) {
        if let selectedPergolaModel = selectedPergolaModel {
            let homeVC = storyboard?.instantiateViewController(withIdentifier: "ARPlaceModelVC") as! ARPlaceModelVC // HomeVC
            homeVC.pergolaModel = selectedPergolaModel
            navigationController?.pushViewController(homeVC, animated: true)
        }
    }
    
    // MARK: - Functions
    private func setupUI() {
        title = "Select pergola design"
        
        btnPlace3DObject.layer.cornerRadius = 10
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ModelSelectionCell", bundle: nil), forCellReuseIdentifier: "ModelSelectionCell")
    }
    
    private func loadModels() {
        let modern = PergolaModel(url: Bundle.main.url(forResource: "Modern", withExtension: "usdz")!,
                               description: "6\" steel beams, louvered sunscreen",
                               scale: SCNVector3(x: 0.09, y: 0.09, z: 0.09),
                               minScale: SCNVector3(x: 0.008, y: 0.008, z: 0.008),
                               eulerAngles: SCNVector3(x: -1.6, y: 0, z: 0))
        
        let traditional = PergolaModel(url: Bundle.main.url(forResource: "Traditional", withExtension: "usdz")!,
                                    description: "Oak 6\" beams",
                                    scale: SCNVector3(x: 0.0009, y: 0.0009, z: 0.0009),
                                    minScale: SCNVector3(x: 0.0002, y: 0.0002, z: 0.0002), eulerAngles: SCNVector3.init())
        
        arrPergolaModel.append(contentsOf: [modern, traditional])
        selectedPergolaModel = modern
    }
    
    /*private func fetchUSDZModelPathsFromBundle() {
        guard let bundlePath = Bundle.main.resourcePath else {
            print("Can't find resourcePath")
            return
        }

        let bundleURL = URL(fileURLWithPath: bundlePath)
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: nil)
            
            // Filter for URLs with the .usdz extension
            let usdzURLs = contents.filter { $0.pathExtension == "usdz" }
            arrModelURLs = usdzURLs
            selectedModelURL = arrModelURLs.first
        } catch {
            print("Error fetching files from bundle: \(error)")
        }
    }*/
}
 
// MARK: - UITableViewDelegate, UITableViewDataSource
extension Select3DObjectVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPergolaModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModelSelectionCell", for: indexPath) as! ModelSelectionCell
        let model = arrPergolaModel[indexPath.row]
        let isSelected = model.url == selectedPergolaModel?.url
        
        cell.lblName.text = model.url.deletingPathExtension().lastPathComponent
        cell.lblDescription.text = model.description
        cell.lblDescription.isHidden = !isSelected //? UIColor.gray : UIColor.systemGray2
        cell.viewContainer.layer.borderColor = isSelected ? UIColor.gray.cgColor : UIColor.clear.cgColor
        cell.viewContainer.layer.borderWidth = isSelected ? 1 : 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPergolaModel = arrPergolaModel[indexPath.row]
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
