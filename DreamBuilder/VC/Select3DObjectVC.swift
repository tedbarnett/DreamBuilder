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
    
    // MARK: - Variable
    var arrPergolaModel: [PergolaModel] = []
    var selectedPergolaModel: PergolaModel?
    
    // MARK: - Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadModels()
        setupUI()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            coordinator.animate(alongsideTransition: { _ in
                // Reload the table view to update cell heights
                self.tableView.reloadData()
            })
        }
    }
        
    // MARK: - Functions
    private func setupUI() {
        title = "Select pergola design"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ModelSelectionCell", bundle: nil), forCellReuseIdentifier: "ModelSelectionCell")
    }
    
    private func loadModels() {
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
        
        arrPergolaModel.append(contentsOf: [modern1, modern2])
        selectedPergolaModel = modern1

        
        /*let pivot6 = PergolaModel(url: Bundle.main.url(forResource: "Modern", withExtension: "usdz")!,
                               description: "6\" steel beams, louvered sunscreen",
                               scale: SCNVector3(x: 0.09, y: 0.09, z: 0.09),
                               minScale: SCNVector3(x: 0.008, y: 0.008, z: 0.008),
                                  eulerAngles: SCNVector3(x: -1.6, y: 0, z: 0), image: .pivot6)
        
        let pivot6XL = PergolaModel(url: Bundle.main.url(forResource: "Modern", withExtension: "usdz")!,
                               description: "6\" steel beams, louvered sunscreen",
                               scale: SCNVector3(x: 0.09, y: 0.09, z: 0.09),
                               minScale: SCNVector3(x: 0.008, y: 0.008, z: 0.008),
                                  eulerAngles: SCNVector3(x: -1.6, y: 0, z: 0), image: .pivot6XL)
        
        let pivot6XLSlide = PergolaModel(url: Bundle.main.url(forResource: "Modern", withExtension: "usdz")!,
                               description: "6\" steel beams, louvered sunscreen",
                               scale: SCNVector3(x: 0.09, y: 0.09, z: 0.09),
                               minScale: SCNVector3(x: 0.008, y: 0.008, z: 0.008),
                                  eulerAngles: SCNVector3(x: -1.6, y: 0, z: 0), image: .pivot6XLSlide)
        
        let pan6 = PergolaModel(url: Bundle.main.url(forResource: "Modern", withExtension: "usdz")!,
                               description: "6\" steel beams, louvered sunscreen",
                               scale: SCNVector3(x: 0.09, y: 0.09, z: 0.09),
                               minScale: SCNVector3(x: 0.008, y: 0.008, z: 0.008),
                                  eulerAngles: SCNVector3(x: -1.6, y: 0, z: 0), image: .pan6)
        
        arrPergolaModel.append(contentsOf: [pivot6, pivot6XL, pivot6XLSlide, pan6])*/
    }
}
 
// MARK: - UITableViewDelegate, UITableViewDataSource
extension Select3DObjectVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPergolaModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModelSelectionCell", for: indexPath) as! ModelSelectionCell
        let model = arrPergolaModel[indexPath.row]
        //cell.imgLogo.image = model.image
        cell.viewContainer.layer.borderColor = UIColor.systemGray4.cgColor
        cell.viewContainer.layer.borderWidth = 1
        
        
        return cell
        
        /*
        let isSelected = model.url == selectedPergolaModel?.url
        
        cell.lblName.text = model.url.deletingPathExtension().lastPathComponent
        cell.lblDescription.text = model.description
        cell.lblDescription.isHidden = !isSelected //? UIColor.gray : UIColor.systemGray2
        cell.viewContainer.layer.borderColor = isSelected ? UIColor.gray.cgColor : UIColor.clear.cgColor
        cell.viewContainer.layer.borderWidth = isSelected ? 1 : 0
        */
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //selectedPergolaModel = arrPergolaModel[indexPath.row]
        //tableView.reloadData()
        
        let arPlaceModelVC = storyboard?.instantiateViewController(withIdentifier: "ARPlaceModelVC") as! ARPlaceModelVC
        arPlaceModelVC.pergolaModel = arrPergolaModel[indexPath.row]
        navigationController?.pushViewController(arPlaceModelVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
             return 80
        } else {
            let isPortrait = UIDevice.current.orientation.isPortrait
            return isPortrait ? 80 : 160
        }
    }
}
