//
//  ARPlaceModelVC.swift
//  DreamBuilder
//
//  Created by iMac on 11/10/24.
//

import UIKit
import ARKit

class ARPlaceModelVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var viewMessage: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblScale: UILabel!

    // MARK: - Variables
    private var arrPlanes: [SCNNode] = []

    private var navRightBarButton: UIButton!
    private var isShowPlanes: Bool = true

    private var modelNode: SCNNode?
    private var directionalLightNode: SCNNode?
    
    var pergolaModel: PergolaModel!

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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sceneView.session.pause()
        removePlane()
        modelNode?.removeFromParentNode()
        modelNode = nil
        
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    // MARK: - Functions
    private func setupSceneView() {
        viewMessage.layer.cornerRadius = 5
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.allowsCameraControl = false
        sceneView.scene = SCNScene()
    }

    private func setupGestures() {
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
    
    private func showMessage(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.lblMessage.text = message
            self?.viewMessage.isHidden = false
            self?.hideMessage()
         }
    }
    
    private func hideMessage() {
        DispatchQueue.main.asyncAfter(deadline: .now()+2.0) { [weak self] in
            self?.viewMessage.isHidden = true
        }
    }

    private func setupNavigationBar() {
        title = pergolaModel.url.deletingPathExtension().lastPathComponent
        navigationController?.navigationBar.tintColor = .label

        navRightBarButton = UIButton(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        navRightBarButton.setImage(.init(systemName: "line.3.horizontal")?.withConfiguration(UIImage.SymbolConfiguration(scale: .large)), for: .normal)
        navRightBarButton.menu = getOptionMenu()
        navRightBarButton.showsMenuAsPrimaryAction = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBarButton)
    }
    
    private func getOptionMenu() -> UIMenu {
        let menuItems: [UIAction] = [UIAction(title: "Show planes", image: UIImage(systemName: "square.stack.3d.up"), state: isShowPlanes ? .on : .off, handler: { [weak self] action in
            guard let self = self else { return }
            self.isShowPlanes.toggle()
            self.updatePlanesVisibility()
            self.navRightBarButton.menu = getOptionMenu()
        })]
        
        let menu =  UIMenu(title: "Menu", image: nil, identifier: nil, options: [], children: menuItems)
        return menu
    }

    // MARK: - AR Session Control
    private func checkCameraPermission() {
        sceneView.session.pause()
        
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
        configuration.isLightEstimationEnabled = true
        //configuration.frameSemantics.insert(.personSegmentationWithDepth)
        
        sceneView.session.run(configuration)

        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
            self.sceneView.addCoaching()
            self.showMessage(Message.findASurfaceToPlaneAnObject)
        }
    }

    private func createPlane(planeAnchor: ARPlaneAnchor, node: SCNNode){
        let planeGeomentry = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width), height: CGFloat(planeAnchor.planeExtent.height))
        planeGeomentry.materials.first?.diffuse.contents = UIColor.green.withAlphaComponent(0.6) //UIColor.blue.withAlphaComponent(0.5)
        planeGeomentry.materials.first?.isDoubleSided = true

        
        let planeNode = SCNNode(geometry: planeGeomentry)
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0.0, z: planeAnchor.center.z)
        planeNode.eulerAngles = SCNVector3(x: Float(Double.pi) / 2, y: 0, z: 0)
        planeNode.name = "Plane Preview"
        planeNode.opacity = isShowPlanes ? 1 : 0
        
        node.addChildNode(planeNode)
        arrPlanes.append(planeNode)
    }
    
    private func updatePlane(planeAnchor: ARPlaneAnchor, node: SCNNode){
        if let planeNode = node.childNodes.first  {
            if let planeGeomentry = node.childNodes.first?.geometry as? SCNPlane{
                planeGeomentry.width = CGFloat(planeAnchor.planeExtent.width)
                planeGeomentry.height = CGFloat(planeAnchor.planeExtent.height)
                planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0.0, z: planeAnchor.center.z)
                planeNode.opacity = isShowPlanes ? 1 : 0
            }
        }
    }

    private func removePlane() {
        arrPlanes.forEach { node in
            node.removeFromParentNode()
        }
        
        arrPlanes.removeAll()
    }
    
    private func updatePlanesVisibility() {
        arrPlanes.forEach { node in
            node.opacity = isShowPlanes ? 1 : 0
        }
    }
    
    private func placeModel(result: ARRaycastResult) {
        let name = pergolaModel.url.lastPathComponent
        guard let modelScene = try? SCNScene(url: pergolaModel.url, options: nil) else {
            showMessage(Message.faileToLoadObject)
            return
        }
        
        let modelNode = modelScene.rootNode.clone()
        let columns = result.worldTransform.columns
        
        modelNode.name = name
        modelNode.castsShadow = true
        modelNode.position = SCNVector3(x: columns.3.x, y: columns.3.y, z: columns.3.z) 
        modelNode.eulerAngles = pergolaModel.eulerAngles
        modelNode.scale = pergolaModel.scale //SCNVector3(x: 0.0009, y: 0.0009, z: 0.0009)
        
        DispatchQueue.main.async {
            self.lblScale.isHidden = false
            self.lblScale.text = "Scale: \(modelNode.scale.x)"
        }

        // Directional light for realistic lighting and shadows
        /*let light = SCNLight()
        light.type = .directional
        light.castsShadow = true
        light.shadowMode = .deferred
        light.shadowColor = UIColor.black.withAlphaComponent(0.75)
        light.intensity = 1000
        
        light.shadowSampleCount = 16
        light.shadowBias = 0.05
        
        if let estimate = sceneView.session.currentFrame?.lightEstimate {
            light.intensity = estimate.ambientIntensity
            light.temperature = estimate.ambientColorTemperature
        }
        
        
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 500 // Adjust to suit the scene
        ambientLight.color = UIColor.white.withAlphaComponent(0.7) // Softer light
        
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        
        
        directionalLightNode = SCNNode()
        directionalLightNode!.light = light
        directionalLightNode!.position = SCNVector3(0, 1, 0) // Adjust based on model placement
        directionalLightNode!.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0) // Angle downwards

        modelNode.addChildNode(directionalLightNode!)
        modelNode.addChildNode(ambientLightNode)*/
        
        self.modelNode = modelNode
        sceneView.scene.rootNode.addChildNode(modelNode)
    }
}

// MARK: - ARSCNViewDelegate
extension ARPlaceModelVC: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        createPlane(planeAnchor: planeAnchor, node: node)
        
        /*if modelNode == nil {
            createPlane(planeAnchor: planeAnchor, node: node)
        }*/
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        updatePlane(planeAnchor: planeAnchor, node: node)
        
        /*if modelNode == nil {
            updatePlane(planeAnchor: planeAnchor, node: node)
        }*/
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        node.enumerateChildNodes { childNode, _ in
            childNode.removeFromParentNode()
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
}

// MARK: - UIGestureRecognizerDelegate
extension ARPlaceModelVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    // MARK: - Gesture Handlers
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard gesture.view is ARSCNView else {
            showMessage(Message.cantPlaceObject)
            return
        }
        
        let touchLocation = gesture.location(in: self.sceneView)
        
        if let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .horizontal), let raycastResult = sceneView.session.raycast(query).first {
            
            if modelNode == nil {
                placeModel(result: raycastResult)
            }
            
            /*if let modelNode = modelNode {
                modelNode.position = SCNVector3(x: raycastResult.worldTransform.columns.3.x, y: raycastResult.worldTransform.columns.3.y, z: raycastResult.worldTransform.columns.3.z)
            }
           else {
                placeModel(result: raycastResult)
            }*/
        } else {
            if modelNode == nil {
                showMessage(Message.cantPlaceObject)
            }
            /*if modelNode == nil {
                showMessage(Message.findASurfaceToPlaneAnObject)
            } else {
                showMessage(Message.cantPlaceObject)
            }*/
            return
        }
    }

    // MARK: - Gesture Handlers
    @objc private func handlePanGesture(_ gesture: ThresholdPanGesture) {
        guard let sceneView = gesture.view as? ARSCNView else {
            showMessage(Message.cantPlaceObject)
            return
        }
        
        // Check if the pan gesture has exceeded the threshold
        if gesture.isThresholdExceeded {
            if let node = modelNode, isNodeVisible(node: node) {
                let touchLocation = gesture.location(in: sceneView)
                
                if let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .horizontal), let raycastResult = sceneView.session.raycast(query).first {
                    
                    let translation = gesture.translation(in: sceneView)
                    
                    node.position = SCNVector3(
                        raycastResult.worldTransform.columns.3.x + Float(translation.x) * 0.001,
                        raycastResult.worldTransform.columns.3.y, // Keep the model's y position on the plane
                        raycastResult.worldTransform.columns.3.z + Float(translation.y) * 0.001
                    )
                    
                    // Reset the gesture translation
                    gesture.setTranslation(.zero, in: sceneView)
                }
            }
        }
    }

    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.view is ARSCNView else { return }

        if let node = modelNode, isNodeVisible(node: node)  {
            let pinchScaleX = Float(gesture.scale) * node.scale.x
            let pinchScaleY = Float(gesture.scale) * node.scale.y
            let pinchScaleZ = Float(gesture.scale) * node.scale.z

            guard pinchScaleX > pergolaModel.minScale.x else { return }
            node.scale = SCNVector3(pinchScaleX, pinchScaleY, pinchScaleZ)

            DispatchQueue.main.async {
                let scale = node.scale.x
                self.lblScale.text = "Scale: \(scale)"
                self.lblScale.isHidden = false
            }

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
