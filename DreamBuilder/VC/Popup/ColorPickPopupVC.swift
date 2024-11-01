//
//  ColorPickPopupVC.swift
//  DreamBuilder
//
//  Created by iMac on 22/10/24.
//

import UIKit

// MARK: - ColorColllectionCell
class ColorColllectionCell: UICollectionViewCell {
    
    // MARK: - IBOutlet
    @IBOutlet weak var viewContainer: UIView!
}

class ColorPickPopupVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Variables
    
    var arrColors: [UIColor] = [
        UIColor(named: "P_Gray") ?? .black,
        UIColor(named: "P_White") ?? .black,
        UIColor(named: "P_Bronze") ?? .black,
        UIColor(named: "P_Beige") ?? .black,
        UIColor(named: "P_Adobe") ?? .black,
        UIColor(named: "P_Black") ?? .black
    ]
    
    var colorDidSelected: ((UIColor)->())?
    var titleStr: String = ""
    
    // MARK: - Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Method
    private func setupUI() {
        lblTitle.text = titleStr
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    // MARK: - Actions
    @IBAction func btnCloseAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ColorPickPopupVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorColllectionCell", for: indexPath) as! ColorColllectionCell
        cell.viewContainer.backgroundColor = arrColors[indexPath.row]
        cell.viewContainer.cornerRadius = 35
        cell.viewContainer.layer.shadowColor = UIColor.black.withAlphaComponent(0.78).cgColor
        cell.viewContainer.layer.shadowOffset = .zero
        cell.viewContainer.layer.shadowRadius = 1
        cell.viewContainer.layer.shadowOpacity = 0.78
        cell.viewContainer.layer.masksToBounds = false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorDidSelected?(arrColors[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 70)
    }
}
