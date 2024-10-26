//
//  ARCameraVC.swift
//  DreamBuilder
//
//  Created by iMac on 22/10/24.
//

import UIKit
import ARKit

class ARCameraVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var viewOptions: UIView!
    @IBOutlet weak var btnSetGround: UIButton!
    @IBOutlet weak var btnChangeModel: UIButton!
    @IBOutlet weak var btnBaseColor: UIButton!
    @IBOutlet weak var btnLouverColor: UILabel!
    @IBOutlet weak var btnLouverAnimate: UILabel!
    @IBOutlet weak var btnLightOnOff: UIButton!
    @IBOutlet weak var btnChangeWidth: UIButton!
    
    // MARK: - Variables
    private var arrPergoals: [PergolaModel] = []
    private var focusSquare = FocusSquare()
    
    internal var dragOnInfinitePlanesEnabled = false
    internal var isLightOn: Bool = false
    internal var animationValue: Float = 0.0

    private var modelNode: SCNNode?
    private var lightNode: SCNNode?
    private var screenCenter: CGPoint?

    private var pergolaModel: PergolaModel!
    var currentTrackingPosition: CGPoint?

    
    // MARK: - Lifeycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Pergola X"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.screenCenter = self.view.bounds.mid
    }
    
    // MARK: - Methods
    private func setupUI() {
        viewOptions.isHidden = true
        btnSetGround.isHidden = false
        
        sceneView.delegate = self
        sceneView.showsStatistics = false
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.allowsCameraControl = false
        sceneView.scene = SCNScene()
        sceneView.session.pause()
        
        let modern = PergolaModel(url: Bundle.main.url(forResource: "Modern", withExtension: "usdz")!,
                                  name: "2 post",
                                  description: "6\" steel beams, louvered sunscreen",
                                  scale: SCNVector3(x: 0.09, y: 0.09, z: 0.09),
                                  minScale: SCNVector3(x: 0.008, y: 0.008, z: 0.008),
                                  eulerAngles: SCNVector3(x: -1.6, y: 0, z: 0),
                                  image: .pivot6, baseColor: .black, louverColor: .gray)
        
        /*let traditinonal = PergolaModel(url: Bundle.main.url(forResource: "Traditional", withExtension: "usdz")!,
                                        name: "4 post",
                                        description: "6\" steel beams, louvered sunscreen",
                                        scale: SCNVector3(x: 0.0009, y: 0.0009, z: 0.0009),
                                        minScale: SCNVector3(x: 0.0002, y: 0.0002, z: 0.0002),
                                        eulerAngles: .init(),
                                        image: .pivot6, baseColor: .black, louverColor: .gray)*/
        
        let availableObjects: [PergolaModel] = {
            let modelsURL = Bundle.main.url(forResource: "Models.scnassets", withExtension: nil)!

            let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!

            return fileEnumerator.compactMap { element in
                let url = element as! URL

                guard url.pathExtension == "scn" && !url.path.contains("lighting") else { return nil }
                return PergolaModel(url: url, name: url.lastPathComponent.replacingOccurrences(of: ".scn", with: ""), description: "", scale: .init(), minScale: .init(), eulerAngles: .init(), image: .pivot6, baseColor: .black, louverColor: .clear)
            }
        }()
        
        self.pergolaModel = modern
        //self.pergolaModel = availableObjects.first(where: {$0.name == "lamp" })
        self.arrPergoals = [modern]
        self.arrPergoals.append(contentsOf: availableObjects)
    }
        
    private func setNavigationMenu() {
        let image = UIImage(systemName: "line.3.horizontal")?.withConfiguration(UIImage.SymbolConfiguration.init(pointSize: 20, weight: .bold))
        let buttonOptions = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        buttonOptions.setImage(image, for: .normal)
        buttonOptions.tintColor = .black
        buttonOptions.addTarget(self, action: #selector(btnMenuAction), for: .touchUpInside)
        buttonOptions.isEnabled = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonOptions)
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        let panGesture = ThresholdPanGesture(target: self, action: #selector(handlePanGesture(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotateGesture(_:)))

        tapGesture.delegate = self
        panGesture.delegate = self
        pinchGesture.delegate = self
        rotateGesture.delegate = self

        sceneView.gestureRecognizers?.removeAll()
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.addGestureRecognizer(panGesture)
        sceneView.addGestureRecognizer(pinchGesture)
        sceneView.addGestureRecognizer(rotateGesture)
    }
    
    private func checkCameraPermission() {
        checkCameraPermission { [weak self] isGranted in
            guard let self = self else { return }
            if isGranted {
                self.startARSession()
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
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
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        //configuration.frameSemantics.insert(.personSegmentationWithDepth)
        sceneView.session.pause()
        sceneView.session.run(configuration)

        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
            //self.sceneView.addCoaching()
            self.setupFocusSquare()
        }
    }
    
    private func setupFocusSquare() {
        focusSquare.unhide()
        focusSquare.removeFromParentNode()
        sceneView.scene.rootNode.addChildNode(focusSquare)
    }
    
    private func updateFocusSquare() {
        DispatchQueue.main.async {
            let (worldPosition, planeAnchor, _) = self.worldPositionFromScreenPosition(self.view.center, objectPos: self.focusSquare.position)
            if let worldPosition = worldPosition {
                self.focusSquare.update(for: worldPosition, planeAnchor: planeAnchor, camera: self.sceneView.session.currentFrame?.camera)
            }
        }
    }
    
    private func isNodeVisible(node: SCNNode) -> Bool {
        if let pointOfView = sceneView.pointOfView {
            let isMaybeVisible = sceneView.isNode(node, insideFrustumOf: pointOfView)
            return isMaybeVisible
        } else {
            return false
        }
    }
    
    private func resetAllValues() {
        self.animationValue = 0
        self.isLightOn = false
    }
    
    private func placeModel(at position: SCNVector3) {
        let name = pergolaModel.url.lastPathComponent
        guard let modelScene = try? SCNScene(url: pergolaModel.url, options: nil) else {
            return
        }
        
        let modelNode = modelScene.rootNode.clone()
        modelNode.name = name
        modelNode.castsShadow = true
        modelNode.position = position
        //modelNode.eulerAngles = pergolaModel.eulerAngles
        //modelNode.scale = pergolaModel.scale
        
        /*let lightNode = SCNNode()
        let tempLightNode = SCNNode()
        let light = SCNLight()
        
        light.type = .omni
        light.color = UIColor(red: 255/255, green: 214/255, blue: 170/255, alpha: 1.0)
        light.intensity = 1
        light.attenuationStartDistance = 0.0
        light.attenuationEndDistance = 0.09
        light.attenuationFalloffExponent = 0.0
        light.castsShadow = false
        lightNode.isHidden = false
        
        tempLightNode.light = light
        tempLightNode.scale = SCNVector3(x: 0.2, y: 0.2, z: 0.2)
        
        let lightNode1 = tempLightNode.clone()
        lightNode1.position = SCNVector3(x: 0, y: -2.850, z: 1.8)
        
        let lightNode2 = tempLightNode.clone()
        lightNode2.position = SCNVector3(x: 0, y: -1.7290037, z: 1.8)
        
        let lightNode3 = tempLightNode.clone()
        lightNode3.position = SCNVector3(x: 0, y: -0.7, z: 1.8)
        
        lightNode.addChildNode(lightNode1)
        lightNode.addChildNode(lightNode2)
        lightNode.addChildNode(lightNode3)
        modelNode.addChildNode(lightNode)
        
        let lightNode = SCNNode()
        if let node = modelNode.childNode(withName: "Mesh409_Group36_Group35_Group34_Model", recursively: true) {
            let light = SCNLight()
            light.type = .omni
            light.intensity = CGFloat(1)
            light.attenuationStartDistance = 0.0
            light.attenuationEndDistance = CGFloat(0.09)
            light.attenuationFalloffExponent = 0.0
            light.castsShadow = false
            lightNode.isHidden = false
            lightNode.light = light
            node.addChildNode(lightNode)
        }
         */
        
        stopAnimation(of: modelNode)
        
        self.sceneView.scene.rootNode.addChildNode(modelNode)
        self.modelNode?.removeFromParentNode()
        self.lightNode?.removeFromParentNode()
        self.modelNode = modelNode
        //self.lightNode = lightNode
        self.resetAllValues()
        
        DispatchQueue.main.async { [weak self] in
            self?.setNavigationMenu()
            self?.manageOptions(isHidden: false)
        }
    }
    
    private func stopAnimation(of modelNode: SCNNode) {
        let animationKeys = modelNode.animationKeys
        
        animationKeys.forEach { key in
            if let animationPlayer = modelNode.animationPlayer(forKey: key) {
                animationPlayer.play()
                animationPlayer.speed = 0.0
            }
        }
        
        // Recursively stop down animations for all child nodes
        modelNode.childNodes.forEach { childNode in
            stopAnimation(of: childNode)
        }
    }
    
    private func updateAnimation(of modelNode: SCNNode, animationValue: CGFloat) {
        let animationKeys = modelNode.animationKeys
        
        animationKeys.forEach { key in
            if let animationPlayer = modelNode.animationPlayer(forKey: key) {
                let timeInteval = TimeInterval(animationValue) * animationPlayer.animation.duration
                animationPlayer.animation.timeOffset = timeInteval
            }
        }
        
        // Recursively update animations for all child nodes
        modelNode.childNodes.forEach { childNode in
            updateAnimation(of: childNode, animationValue: animationValue)
        }
    }
    
    private func updateBaseColor(of modelNode: SCNNode, color: UIColor) {
        if let material =  modelNode.geometry?.material(named: "Black") {
            material.diffuse.contents = color
         
        }
        
        modelNode.childNodes.forEach { childNode in
            updateBaseColor(of: childNode, color: color)
        }
    }
    
    private func updateLouverColor(of modelNode: SCNNode, color: UIColor) {
        if let material =  modelNode.geometry?.material(named: "FrontColor") {
            material.diffuse.contents = color
            material.selfIllumination.contents = color
            material.normal.contents = color
            material.multiply.contents = color
            material.clearCoatNormal.contents = color
        }
        
        modelNode.childNodes.forEach { childNode in
            updateLouverColor(of: childNode, color: color)
        }
    }
    
    private func updateLight(isLightOn: Bool) {
        guard let lightNode = lightNode else { return }
        lightNode.isHidden = !isLightOn
    }
     
    // MARK: - Actions
    @objc private func btnMenuAction() {
        manageOptions(isHidden: !viewOptions.isHidden)
    }
    
    private func manageOptions(isHidden: Bool) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.viewOptions.isHidden = isHidden
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func btnSetGroundAction(_ sender: UIButton) {
        sender.isHidden = true
        checkCameraPermission()
    }
    
    @IBAction func btnChangeModelAction(_ sender: UIButton) {
        let changeModelPopupVC = storyboard?.instantiateViewController(withIdentifier: "ChangeModelPopupVC") as! ChangeModelPopupVC
        changeModelPopupVC.arrPergoals = arrPergoals
        changeModelPopupVC.pergolaModelDidSelected = { [weak self] pergolaModel in
            guard let self = self else { return }
            if let modelNode = self.modelNode {
                let position = modelNode.position
                self.pergolaModel = pergolaModel
                self.placeModel(at: position)
            }
        }
        
        if let sheet = changeModelPopupVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom { _ in
                return 250
            }
            
            sheet.detents = [customDetent, .medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
                
        changeModelPopupVC.modalPresentationStyle = .pageSheet
        present(changeModelPopupVC, animated: true)
    }
    
    @IBAction func btnBaseColorAction(_ sender: UIButton) {
        let colorPickPopupVC = storyboard?.instantiateViewController(withIdentifier: "ColorPickPopupVC") as! ColorPickPopupVC
        
        colorPickPopupVC.titleStr = "Base color"
        colorPickPopupVC.colorDidSelected = { [weak self] color in
            guard let self = self, let modelNode = self.modelNode else { return }
            self.updateBaseColor(of: modelNode, color: color)
        }
        
        if let sheet = colorPickPopupVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom { _ in
                return 200
            }
            
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        colorPickPopupVC.modalPresentationStyle = .pageSheet
        present(colorPickPopupVC, animated: true)
    }
    
    @IBAction func btnLouverColorAction(_ sender: UIButton) {
        let colorPickPopupVC = storyboard?.instantiateViewController(withIdentifier: "ColorPickPopupVC") as! ColorPickPopupVC
        
        colorPickPopupVC.titleStr = "Louver color"
        colorPickPopupVC.colorDidSelected = { [weak self] color in
            guard let self = self, let modelNode = self.modelNode else { return }
            self.updateLouverColor(of: modelNode, color: color)
        }
        
        if let sheet = colorPickPopupVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom { _ in
                return 200
            }
            
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        colorPickPopupVC.modalPresentationStyle = .pageSheet
        present(colorPickPopupVC, animated: true)
    }
    
    @IBAction func btnLouverAnimateAction(_ sender: UIButton) {
        let adjustAnimationPopupVC = storyboard?.instantiateViewController(withIdentifier: "AdjustAnimationPopupVC") as! AdjustAnimationPopupVC
        
        adjustAnimationPopupVC.titleStr = "Louver animate"
        adjustAnimationPopupVC.minimumValue = 0
        adjustAnimationPopupVC.maximumValue = 100
        adjustAnimationPopupVC.value = self.animationValue
        adjustAnimationPopupVC.sliderValueDidChange = { [weak self] value in
            guard let self = self, let modelNode = self.modelNode else { return }
            self.animationValue = value
            self.updateAnimation(of: modelNode, animationValue: CGFloat(value))
        }
        
        if let sheet = adjustAnimationPopupVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom { _ in
                return 200
            }
            
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        adjustAnimationPopupVC.modalPresentationStyle = .pageSheet
        present(adjustAnimationPopupVC, animated: true)
    }
    
    @IBAction func btnLightOnOffAction(_ sender: UIButton) {
        let adjustLightPopupVC = storyboard?.instantiateViewController(withIdentifier: "AdjustLightPopupVC") as! AdjustLightPopupVC
        
        adjustLightPopupVC.isLightOn = isLightOn
        adjustLightPopupVC.lightStateDidUpdated = { [weak self] isLightOn in
            guard let self = self else { return }
            self.isLightOn = isLightOn
            self.updateLight(isLightOn: isLightOn)
        }
        
        if let sheet = adjustLightPopupVC.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom { _ in
                return 200
            }
            
            sheet.detents = [customDetent]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        adjustLightPopupVC.modalPresentationStyle = .pageSheet
        present(adjustLightPopupVC, animated: true)
        
    }
    
    @IBAction func btnChangeWidthAction(_ sender: UIButton) {
        
    }
}

// MARK: - ARSCNViewDelegate
extension ARCameraVC: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        node.enumerateChildNodes { childNode, _ in
            childNode.removeFromParentNode()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if modelNode == nil {
            self.updateFocusSquare()
        } else {
            self.focusSquare.removeFromParentNode()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ARCameraVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    // MARK: - Gesture Handlers
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard gesture.view is ARSCNView else {
            return
        }
        
        let touchLocation = gesture.location(in: self.sceneView)
        
        if let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .horizontal), let raycastResult = sceneView.session.raycast(query).first {
            if modelNode == nil {
                let columns = raycastResult.worldTransform.columns
                placeModel(at: SCNVector3(x: columns.3.x, y: columns.3.y, z: columns.3.z) )
            }
        }
    }

    // MARK: - Gesture Handlers
    @objc private func handlePanGesture(_ gesture: ThresholdPanGesture) {
        guard let sceneView = gesture.view as? ARSCNView else {
            return
        }
        
        // Check if the pan gesture has exceeded the threshold
        if gesture.isThresholdExceeded {
            if let node = modelNode, isNodeVisible(node: node) {
                let touchLocation = gesture.location(in: sceneView)
                
                if let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .horizontal), let raycastResult = sceneView.session.raycast(query).first {
                    
                    let translation = gesture.translation(in: sceneView)
                    
                    node.position = SCNVector3(
                        raycastResult.worldTransform.columns.3.x + Float(translation.x) * 0.001,
                        raycastResult.worldTransform.columns.3.y, // Keep the model's y position on the plane
                        raycastResult.worldTransform.columns.3.z + Float(translation.y) * 0.001
                    )
                    
                    gesture.setTranslation(.zero, in: sceneView)
                }
            }
        }
    }
    
    /*@objc private func handlePanGesture(_ gesture: ThresholdPanGesture) {
        guard let sceneView = gesture.view as? ARSCNView else {
            return
        }
        
        switch gesture.state {
        case .changed where gesture.isThresholdExceeded:
            guard let node = modelNode else { return }
            let position = updatedTrackingPosition(for: node, from: gesture)
            
            if let query = sceneView.raycastQuery(from: position, allowing: .estimatedPlane, alignment: .horizontal), let raycastResult = sceneView.session.raycast(query).first {
                setTransform(of: node, with: raycastResult)
            }
            
            gesture.setTranslation(.zero, in: sceneView)
            
        case .changed:
            // Ignore the pan gesture until the displacment threshold is exceeded.
            break
        default:
            break
        }
    }
    
    func setTransform(of node: SCNNode, with result: ARRaycastResult) {
        node.simdWorldTransform = result.worldTransform
    }
    
    func setDown(node: SCNNode, basedOn screenPos: CGPoint) {
        // Attempt to create a new tracked raycast from the current location.
        if let query = sceneView.raycastQuery(from: screenPos, allowing: .estimatedPlane, alignment: .horizontal), let raycastResult = sceneView.session.raycast(query).first {
            setTransform(of: node, with: raycastResult)
        }
    }
    
    func updatedTrackingPosition(for node: SCNNode, from gesture: UIPanGestureRecognizer) -> CGPoint {
        let translation = gesture.translation(in: sceneView)
        
        let currentPosition = currentTrackingPosition ?? CGPoint(sceneView.projectPoint(node.position))
        let updatedPosition = CGPoint(x: currentPosition.x + translation.x, y: currentPosition.y + translation.y)
        currentTrackingPosition = updatedPosition
        return updatedPosition
    }*/
    
    /*@objc private func handlePanGesture(_ gesture: ThresholdPanGesture) {
        guard let sceneView = gesture.view as? ARSCNView else {
            return
        }

        // Check if the pan gesture has exceeded the threshold
        if gesture.isThresholdExceeded {
            if let node = modelNode, isNodeVisible(node: node) {
                let touchLocation = gesture.location(in: sceneView)

                // Perform raycast to get the position on the detected plane
                if let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .horizontal),
                   let raycastResult = sceneView.session.raycast(query).first {

                    let translation = gesture.translation(in: sceneView)

                    // Get the world position based on raycast result
                    let raycastWorldPosition = SCNVector3(
                        raycastResult.worldTransform.columns.3.x,
                        raycastResult.worldTransform.columns.3.y,
                        raycastResult.worldTransform.columns.3.z
                    )
                    
                    // Get current object position and calculate smooth movement
                    let objectWorldPosition = node.position

                    // Adjust the position smoothly, based on touch translation
                    let smoothPosition = SCNVector3(
                        raycastWorldPosition.x + Float(translation.x) * 0.001,
                        objectWorldPosition.y, // Keep the Y (height) fixed
                        raycastWorldPosition.z + Float(translation.y) * 0.001
                    )

                    // Apply filtered position to make movement smooth (you can adjust this logic)
                    node.position = smoothPosition

                    // Reset the translation for next movement
                    gesture.setTranslation(.zero, in: sceneView)
                }
            }
        }
    }*/


    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.view is ARSCNView else { return }

        if let node = modelNode, isNodeVisible(node: node) {
            let pinchScaleX = Float(gesture.scale) * node.scale.x
            let pinchScaleY = Float(gesture.scale) * node.scale.y
            let pinchScaleZ = Float(gesture.scale) * node.scale.z

            guard pinchScaleX > pergolaModel.minScale.x else { return }
            node.scale = SCNVector3(pinchScaleX, pinchScaleY, pinchScaleZ)
            gesture.scale = 1.0
        }
    }

    @objc private func handleRotateGesture(_ gesture: UIRotationGestureRecognizer) {
        guard gesture.state == .changed else { return }
        guard gesture.view is ARSCNView else { return }

        if let node = modelNode, isNodeVisible(node: node) {
            node.eulerAngles.y -= Float(gesture.rotation)
            gesture.rotation = 0
        }
    }
}

extension ARCameraVC {

    // Code from Apple PlacingObjects demo: https://developer.apple.com/sample-code/wwdc/2017/PlacingObjects.zip

    func worldPositionFromScreenPosition(_ position: CGPoint,
                                         objectPos: SCNVector3?,
                                         infinitePlane: Bool = false) -> (position: SCNVector3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {

        // -------------------------------------------------------------------------------
        // 1. Always do a hit test against exisiting plane anchors first.
        //    (If any such anchors exist & only within their extents.)
        guard let query = sceneView.raycastQuery(from: position, allowing: .existingPlaneGeometry, alignment: .horizontal) else {
            return (nil, nil, false)
        }
        
        let planeHitTestResults = sceneView.session.raycast(query)
        
        
        //let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {

            let planeHitTestPosition = SCNVector3.positionFromTransform(result.worldTransform)
            let planeAnchor = result.anchor

            // Return immediately - this is the best possible outcome.
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }

        // -------------------------------------------------------------------------------
        // 2. Collect more information about the environment by hit testing against
        //    the feature point cloud, but do not return the result yet.

        var featureHitTestPosition: SCNVector3?
        var highQualityFeatureHitTestResult = false

        let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)

        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }

        // -------------------------------------------------------------------------------
        // 3. If desired or necessary (no good feature hit test result): Hit test
        //    against an infinite, horizontal plane (ignoring the real world).

        if (infinitePlane && dragOnInfinitePlanesEnabled) || !highQualityFeatureHitTestResult {

            let pointOnPlane = objectPos ?? SCNVector3Zero

            let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
            if pointOnInfinitePlane != nil {
                return (pointOnInfinitePlane, nil, true)
            }
        }

        // -------------------------------------------------------------------------------
        // 4. If available, return the result of the hit test against high quality
        //    features if the hit tests against infinite planes were skipped or no
        //    infinite plane was hit.

        if highQualityFeatureHitTestResult {
            return (featureHitTestPosition, nil, false)
        }

        // -------------------------------------------------------------------------------
        // 5. As a last resort, perform a second, unfiltered hit test against features.
        //    If there are no features in the scene, the result returned here will be nil.

        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            let result = unfilteredFeatureHitTestResults[0]
            return (result.position, nil, false)
        }

        return (nil, nil, false)
    }

}

