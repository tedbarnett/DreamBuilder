//
//  Select3DObjectVC.swift
//  DreamBuilder
//
//  Created by iMac on 07/10/24.
//

import UIKit

class Select3DObjectVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnPlace3DObject: UIButton!
    
    // MARK: - Variable
    var arrModelURLs: [URL] = []
    var selectedModelURL: URL?
    
    // MARK: - Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUSDZModelPathsFromBundle()
        setupUI()
    }
    
    // MARK: - Action
    @IBAction func btnPlace3DObjectAction(_ sender: UIButton) {
        if let modelURL = selectedModelURL {
            let homeVC = storyboard?.instantiateViewController(withIdentifier: "ARPlaceModelVC") as! ARPlaceModelVC // HomeVC 
            homeVC.modelURL = modelURL
            navigationController?.pushViewController(homeVC, animated: true)
        }
    }
    
    // MARK: - Functions
    private func setupUI() {
        title = "Select 3D Object"
        
        btnPlace3DObject.layer.cornerRadius = 10
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ModelSelectionCell", bundle: nil), forCellReuseIdentifier: "ModelSelectionCell")
    }
    
    private func fetchUSDZModelPathsFromBundle() {
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
    }
}
 
// MARK: - UITableViewDelegate, UITableViewDataSource
extension Select3DObjectVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrModelURLs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModelSelectionCell", for: indexPath) as! ModelSelectionCell
        let modelURL = arrModelURLs[indexPath.row]
        let isSelected = modelURL == selectedModelURL
        
        cell.lblName.text = modelURL.deletingPathExtension().lastPathComponent
        cell.viewContainer.layer.borderColor = isSelected ? UIColor.gray.cgColor : UIColor.clear.cgColor
        cell.viewContainer.layer.borderWidth = isSelected ? 1 : 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedModelURL = arrModelURLs[indexPath.row]
        tableView.reloadData()
    }
}
