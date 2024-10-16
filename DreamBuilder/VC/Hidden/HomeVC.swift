//
//  HomeVC.swift
//  DreamBuilder
//
//  Created by iMac on 03/10/24.
//

//import UIKit
//import SceneKit
//import ARKit
//import FSPopoverView
//
//class HomeVC: UIViewController {
//    
//    // MARK: - IBOutlets
//    @IBOutlet weak var lblScale: UILabel!
//    @IBOutlet weak var sceneView: ARSCNView!
//    
//    // MARK: - Variable
//    private var modelNode: SCNNode?
//    private var lightNode: SCNNode?
//    private var navRightBarButton: UIButton!
//    private var light: Float = 0.5
//    
//    var modelURL: URL!
//    
//    // MARK: - Lifecycle Methods
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupSceneView()
//        setupGestures()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        setupNavigationBar()
//        checkCameraPermission()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        sceneView.session.pause()
//    }
//    
//    // MARK: - Setup Scene and Gestures
//    private func setupSceneView() {
//        sceneView.delegate = self
//        sceneView.showsStatistics = true
//        sceneView.autoenablesDefaultLighting = true
//        sceneView.automaticallyUpdatesLighting = true
//        sceneView.allowsCameraControl = false
//        sceneView.scene = SCNScene()
//        sceneView.addCoaching()
//    }
//    
//    private func setupNavigationBar() {
//        title = modelURL.deletingPathExtension().lastPathComponent
//        navigationController?.navigationBar.tintColor = .label
//        
//        navRightBarButton = UIButton(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
//        navRightBarButton.setImage(.init(systemName: "scale.3d"), for: .normal)
//        navRightBarButton.addTarget(self, action: #selector(btnLightSliderAction(_:)), for: .touchUpInside)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBarButton)
//    }
//    
//    @objc private func btnLightSliderAction(_ sender: UIButton) {
//        showPopOverMenu(on: navRightBarButton)
//    }
//    
//    private func setupGestures() {
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
//        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
//        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotateGesture(_:)))
//        
//        panGesture.delegate = self
//        pinchGesture.delegate = self
//        rotateGesture.delegate = self
//        
//        sceneView.gestureRecognizers?.removeAll()
//        sceneView.addGestureRecognizer(panGesture)
//        sceneView.addGestureRecognizer(pinchGesture)
//        sceneView.addGestureRecognizer(rotateGesture)
//    }
//    
//    // MARK: - AR Session Control
//    private func checkCameraPermission() {
//        sceneView.session.pause()
//        
//        checkCameraPermission { [weak self] isGranted in
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                if isGranted {
//                    self.startARSession()
//                } else {
//                    self.showCameraPermissionAlert()
//                }
//            }
//        }
//    }
//    
//    private func startARSession() {
//        guard ARWorldTrackingConfiguration.isSupported else {
//            #if !targetEnvironment(simulator)
//            showUnsupportedPlatformAlert { [weak self] in
//                guard let self = self else { return }
//                self.navigationController?.popViewController(animated: true)
//            }
//            #endif
//            return
//        }
//
//        UIApplication.shared.isIdleTimerDisabled = true
//
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal
//        configuration.isLightEstimationEnabled = true
//        configuration.worldAlignment = .camera
//        sceneView.session.run(configuration)
//    }
//
//    private func placeModelAt(anchor: ARPlaneAnchor, on node: SCNNode) {
//        let name = modelURL.lastPathComponent
//        guard let modelScene = SCNScene(named: name) else {
//            print("Error loading model")
//            return
//        }
//        
//        let modelNode = modelScene.rootNode.clone()
//        modelNode.scale = SCNVector3(x: 0.0009, y: 0.0009, z: 0.0009) //SCNVector3(x: 0.005, y: 0.005, z: 0.005)
//        modelNode.name = name
//        modelNode.castsShadow = true
//        node.addChildNode(modelNode)
//        
//        self.modelNode = modelNode
//        
//        // Create and configure the light
//        let light = SCNLight()
//        light.type = .directional
//        light.color = UIColor.white
//        light.intensity = CGFloat(self.light * 1000) // Scale for more visible light
//
//        lightNode = SCNNode()
//        lightNode?.light = light
//        lightNode?.position = SCNVector3(x: 0, y: 10, z: 10) // Position the light above the model
//        lightNode?.look(at: modelNode.position) // Make light point to the model
//        node.addChildNode(lightNode!)
//
//        print("Model Node and Light Node Added")
//
//        DispatchQueue.main.async {
//            self.lblScale.isHidden = false
//            let scale = modelNode.scale.x
//            print(scale)
//            self.lblScale.text = "Scale: \(scale)"
//        }
//    }
//
//    
//    // MARK: - Check if model is visible on camera or not
//    private func isNodeVisible(node: SCNNode) -> Bool {
//        if let pointOfView = sceneView.pointOfView {
//            let isMaybeVisible = sceneView.isNode(node, insideFrustumOf: pointOfView)
//            print("is Node Visible: \(isMaybeVisible)")
//            return isMaybeVisible
//        } else {
//            print("is Node Visible: false")
//            return false
//        }
//    }
//    
//    private func showPopOverMenu(on view: UIView) {
//        //if let node = modelNode, isNodeVisible(node: node) {
//            let arrOptionStr: [String] = ["Adjust Light"]
//            let arrListItems: [FSPopoverListItem] = arrOptionStr.map {  option in
//                let item = FSPopoverListTextItem()
//                item.title = option
//                item.isSeparatorHidden = false
//                item.selectedHandler = { [weak self] item in
//                    guard let self = self else { return }
//                    guard let title = (item as? FSPopoverListTextItem)?.title else { return }
//                    
//                    if title == "Adjust Light" {
//                        openAdjustLightPopupVC()
//                    }
//                }
//                item.updateLayout()
//                return item
//            }
//            
//            arrListItems.last?.isSeparatorHidden = true
//            
//            let listView = FSPopoverListView()
//            listView.items = arrListItems
//            listView.present(fromRect: view.convert(view.bounds, to: self.view), in: self.view)
//        //}
//    }
//    
//    private func openAdjustLightPopupVC() {
//        let adjustLightPopupVC = storyboard?.instantiateViewController(withIdentifier: "AdjustLightPopupVC") as! AdjustLightPopupVC
//        
//        adjustLightPopupVC.modalPresentationStyle = .pageSheet
//
//        adjustLightPopupVC.light = self.light
//        adjustLightPopupVC.lightSliderValueDidChange = { [weak self] value in
//            guard let self = self else { return }
//            self.light = value
//            self.lightNode?.light?.intensity = CGFloat(value * 1000) // Update the light intensity
//        }
//        
//        
//        if let sheet = adjustLightPopupVC.sheetPresentationController {
//            sheet.detents = [.medium()]
//            sheet.prefersGrabberVisible = true
//            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
//        }
//        
//        present(adjustLightPopupVC, animated: true, completion: nil)
//    }
//
//}
//
//// MARK: - ARSCNViewDelegate
//extension HomeVC: ARSCNViewDelegate {
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        guard let planeAnchor = anchor as? ARPlaneAnchor, self.modelNode == nil else { return }
//        placeModelAt(anchor: planeAnchor, on: node)
//    }
//}
//
//// MARK: - UIGestureRecognizerDelegate
//extension HomeVC: UIGestureRecognizerDelegate {
//    
//    // Ensure multiple gesture is active at a time
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//    
//    // MARK: - Gesture Handlers
//    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
//        guard let sceneView = gesture.view as? ARSCNView else { return }
//        
//        if let node = modelNode, isNodeVisible(node: node) {
//            let translation = gesture.translation(in: sceneView)
//            let currentPosition = node.position
//            
//            node.position = SCNVector3(
//                currentPosition.x + Float(translation.x) * 0.001,
//                currentPosition.y,
//                currentPosition.z + Float(translation.y) * 0.001
//            )
//            
//            gesture.setTranslation(.zero, in: sceneView)
//        }
//    }
//    
//    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
//        guard gesture.view is ARSCNView else { return }
//        
//        if let node = modelNode, isNodeVisible(node: node)  {
//            let pinchScaleX = Float(gesture.scale) * node.scale.x
//            let pinchScaleY = Float(gesture.scale) * node.scale.y
//            let pinchScaleZ = Float(gesture.scale) * node.scale.z
//            
//            guard pinchScaleX > 0.0002 else { return }
//            node.scale = SCNVector3(pinchScaleX, pinchScaleY, pinchScaleZ)
//            
//            DispatchQueue.main.async {
//                let scale = node.scale.x
//                print(scale)
//                self.lblScale.text = "Scale: \(scale)"
//            }
//            
//            gesture.scale = 1.0
//        }
//    }
//
//    @objc private func handleRotateGesture(_ gesture: UIRotationGestureRecognizer) {
//        guard gesture.view is ARSCNView else { return }
//        
//        if let node = modelNode, isNodeVisible(node: node) {
//            node.eulerAngles.y -= Float(gesture.rotation)
//            gesture.rotation = 0
//        }
//    }
//}

import UIKit
import SceneKit
import ARKit
import FSPopoverView

class HomeVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var lblScale: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    // MARK: - Variables
    private var modelNode: SCNNode?
    private var lightNode: SCNNode?
    private var navRightBarButton: UIButton!
    private var light: Float = 0.5
    
    var modelURL: URL!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneView()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        checkCameraPermission()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Functions
    private func setupSceneView() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.allowsCameraControl = false
        sceneView.scene = SCNScene()
        sceneView.addCoaching()
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotateGesture(_:)))
        
        panGesture.delegate = self
        pinchGesture.delegate = self
        rotateGesture.delegate = self
        
        sceneView.gestureRecognizers?.removeAll()
        sceneView.addGestureRecognizer(panGesture)
        sceneView.addGestureRecognizer(pinchGesture)
        sceneView.addGestureRecognizer(rotateGesture)
    }
    
    private func setupNavigationBar() {
        title = modelURL.deletingPathExtension().lastPathComponent
        navigationController?.navigationBar.tintColor = .label
        
        navRightBarButton = UIButton(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        navRightBarButton.setImage(.init(systemName: "scale.3d")?.withConfiguration(UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        navRightBarButton.addTarget(self, action: #selector(btnLightSliderAction(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBarButton)
    }
    
    @objc private func btnLightSliderAction(_ sender: UIButton) {
        showPopOverMenu(on: navRightBarButton)
    }
    
    // MARK: - AR Session Control
    private func checkCameraPermission() {
        sceneView.session.pause()
        
        checkCameraPermission { [weak self] isGranted in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if isGranted {
                    self.startARSession()
                } else {
                    self.showCameraPermissionAlert()
                }
            }
        }
    }
    
    private func startARSession() {
#if !targetEnvironment(simulator)
        guard ARWorldTrackingConfiguration.isSupported else {
            showUnsupportedPlatformAlert { [weak self] in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
#endif
        UIApplication.shared.isIdleTimerDisabled = true

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        configuration.worldAlignment = .camera
        sceneView.session.run(configuration)
    }

    private func placeModelAt(anchor: ARPlaneAnchor, on node: SCNNode) {
        let name = modelURL.lastPathComponent
        guard let modelScene = SCNScene(named: name) else {
            print("Error loading model")
            return
        }
        
        let modelNode = modelScene.rootNode.clone()
        modelNode.scale = SCNVector3(x: 0.0009, y: 0.0009, z: 0.0009) //SCNVector3(x: 0.005, y: 0.005, z: 0.005)
        modelNode.name = name
        modelNode.castsShadow = true
        node.addChildNode(modelNode)
        
        self.modelNode = modelNode
        
        // Create and configure the light
        let light = SCNLight()
        light.type = .directional
        light.color = UIColor.white
        light.intensity = CGFloat(self.light * 1000)
        light.shadowRadius = CGFloat(self.light * 1000)
        light.shadowColor = UIColor.black.withAlphaComponent(CGFloat(self.light))
        light.castsShadow = true

        lightNode = SCNNode()
        lightNode?.light = light
        lightNode?.position = SCNVector3(x: 0, y: 10, z: 10)
        lightNode?.look(at: modelNode.position)
        node.addChildNode(lightNode!)

        print("Model Node and Light Node Added")

        DispatchQueue.main.async {
            self.lblScale.isHidden = false
            let scale = modelNode.scale.x
            print(scale)
            self.lblScale.text = "Scale: \(scale)"
        }
    }
    
    private func isNodeVisible(node: SCNNode) -> Bool {
        // check the node is visible in sceneview
        if let pointOfView = sceneView.pointOfView {
            let isMaybeVisible = sceneView.isNode(node, insideFrustumOf: pointOfView)
            print("is Node Visible: \(isMaybeVisible)")
            return isMaybeVisible
        } else {
            print("is Node Visible: false")
            return false
        }
    }
    
    private func showPopOverMenu(on view: UIView) {
        
        let arrOptionStr: [String] = ["Adjust Light"]
        let arrListItems: [FSPopoverListItem] = arrOptionStr.map {  option in
            let item = FSPopoverListTextItem()
            item.title = option
            item.isSeparatorHidden = false
            item.selectedHandler = { [weak self] item in
                guard let self = self else { return }
                guard let title = (item as? FSPopoverListTextItem)?.title else { return }
                
                #if !targetEnvironment(simulator)
                guard modelNode != nil else {
                    print("Light: Model Node is not added!!")
                    return
                }
                #endif
                
                if title == "Adjust Light" {
                    openAdjustLightPopupVC()
                }
            }
            item.updateLayout()
            return item
        }
        
        arrListItems.last?.isSeparatorHidden = true
        
        let listView = FSPopoverListView()
        var bounds = view.convert(view.bounds, to: self.view)
        bounds.origin.y = -5
        bounds.origin.x = -1
        bounds = view.convert(bounds, to: self.view)
        
        listView.items = arrListItems
        listView.present(fromRect: bounds, in: self.view)
    }
    
    private func openAdjustLightPopupVC() {
        let adjustLightPopupVC = storyboard?.instantiateViewController(withIdentifier: "AdjustLightPopupVC") as! AdjustLightPopupVC
        
        
        adjustLightPopupVC.light = self.light
        
        adjustLightPopupVC.lightSliderValueDidChange = { [weak self] value in
            guard let self = self else { return }
            self.light = value
            self.lightNode?.light?.intensity = CGFloat(value * 1000)
            self.lightNode?.light?.intensity = CGFloat(self.light * 1000)
            self.lightNode?.light?.shadowRadius = CGFloat(self.light * 1000)
            self.lightNode?.light?.shadowColor = UIColor.black.withAlphaComponent(CGFloat(self.light))
        }
        
        if #available(iOS 15.0, *) {
            if let sheet = adjustLightPopupVC.sheetPresentationController {
                
                if #available(iOS 16.0, *) {
                    sheet.detents = [.custom(resolver: { context in
                        return 180
                    })]
                } else {
                    sheet.detents = [.medium()]
                }
                
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
        } else {
            adjustLightPopupVC.modalPresentationStyle = .pageSheet
        }
        
        present(adjustLightPopupVC, animated: true, completion: nil)
    }
}

// MARK: - ARSCNViewDelegate
extension HomeVC: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, self.modelNode == nil else { return }
        placeModelAt(anchor: planeAnchor, on: node)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension HomeVC: UIGestureRecognizerDelegate {
    
    // Ensure multiple gesture is active at a time
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Gesture Handlers
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let sceneView = gesture.view as? ARSCNView else { return }
        
        if let node = modelNode, isNodeVisible(node: node) {
            let translation = gesture.translation(in: sceneView)
            let currentPosition = node.position
            
            node.position = SCNVector3(
                currentPosition.x + Float(translation.x) * 0.001,
                currentPosition.y,
                currentPosition.z + Float(translation.y) * 0.001
            )
            
            gesture.setTranslation(.zero, in: sceneView)
        }
    }
    
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.view is ARSCNView else { return }
        
        if let node = modelNode, isNodeVisible(node: node)  {
            let pinchScaleX = Float(gesture.scale) * node.scale.x
            let pinchScaleY = Float(gesture.scale) * node.scale.y
            let pinchScaleZ = Float(gesture.scale) * node.scale.z
            
            guard pinchScaleX > 0.0002 else { return }
            node.scale = SCNVector3(pinchScaleX, pinchScaleY, pinchScaleZ)
            
            DispatchQueue.main.async {
                let scale = node.scale.x
                print(scale)
                self.lblScale.text = "Scale: \(scale)"
            }
            
            gesture.scale = 1.0
        }
    }

    @objc private func handleRotateGesture(_ gesture: UIRotationGestureRecognizer) {
        guard gesture.view is ARSCNView else { return }
        
        if let node = modelNode, isNodeVisible(node: node) {
            node.eulerAngles.y -= Float(gesture.rotation)
            gesture.rotation = 0
        }
    }
}
