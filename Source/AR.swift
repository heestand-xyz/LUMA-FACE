//
//  AR.swift
//  Luma Face
//
//  Created by Hexagons on 2018-11-24.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import ARKit

protocol ARMirror {
    func activityUpdated(_ active: Bool)
    func didUpdate(arFrame: ARFrame)
    func didAdd()
    func didUpdate(geo: ARFaceGeometry)
    func didRemove()
}

class AR: NSObject, ARSessionDelegate, ARSCNViewDelegate {
    
    var mirrors: [ARMirror] = []
    
    static var isSupported: Bool {
        return ARFaceTrackingConfiguration.isSupported
    }
    
    let view: UIView
    
    let session: ARSession
    let scnView: ARSCNView
    
    var lowFps: Bool = false
    
    var node: SCNNode?
    
    var lastUpdate: Date?
    var lastActive: Bool {
        guard let date = lastUpdate else { return false }
        let time = -date.timeIntervalSinceNow
        return time < 0.1
    }
    var isActive: Bool = false
    
    var image: UIImage?
    
//    var image: UIImage?
    
//    var faceAnchor: ARFaceAnchor?
//    let scnFaceGeometry: ARSCNFaceGeometry
//    let faceNode: SCNNode
    
    init(frame: CGRect) {
        
        view = UIView(frame: frame)
        
        session = ARSession()
        
        scnView = ARSCNView(frame: view.bounds)
        
//        let device: MTLDevice = scnView.device!
//        scnFaceGeometry = ARSCNFaceGeometry(device: device)!
//        faceNode = SCNNode()
        
        
        super.init()
        
        
        session.delegate = self
        
        scnView.session = session
        scnView.delegate = self
        view.addSubview(scnView)
        
//        scnFaceGeometry.firstMaterial!.fillMode = .lines
//        faceNode.geometry = scnFaceGeometry
        
//        mirror?.didSetup(cam: scnView.scene.rootNode.camera!)
        
        let bgSphere = SCNSphere(radius: 10)
        bgSphere.firstMaterial!.isDoubleSided = true
        bgSphere.firstMaterial!.diffuse.contents = UIColor.black
        let bgNode = SCNNode(geometry: bgSphere)
        scnView.scene.rootNode.addChildNode(bgNode)

    }
    
    func run() {
        let config = ARFaceTrackingConfiguration()
        if lowFps {
            if #available(iOS 11.3, *) {
                config.videoFormat = ARFaceTrackingConfiguration.supportedVideoFormats.last!
            }
        }
        config.isLightEstimationEnabled = false
        let options: ARSession.RunOptions = [
            .resetTracking,
            .removeExistingAnchors
        ]
        session.run(config, options: options)
    }
    
    func pause() {
        session.pause()
    }
    
    func addImage(_ image: UIImage) {
        guard node != nil else { return }
        node!.geometry!.firstMaterial!.fillMode = .fill
        node!.geometry!.firstMaterial!.diffuse.contents = image
        self.image = image
    }
    
    func removeImage() {
        guard node != nil else { return }
        node!.geometry!.firstMaterial!.fillMode = .lines
        node!.geometry!.firstMaterial!.diffuse.contents = nil
        self.image = nil
    }
    
    // MARK: ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        print("AR SE FRAME")
        if isActive != lastActive {
            isActive = lastActive
            print("AR ACTIVE", isActive)
            mirrors.forEach { mirror in
                mirror.activityUpdated(isActive)
            }
        }
        mirrors.forEach { mirror in
            mirror.didUpdate(arFrame: frame)
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        print("AR SE ADD", anchors.count)
        mirrors.forEach { mirror in
            mirror.didAdd()
        }
////        guard faceAnchor == nil else { print("FACE too late.."); return }
////        faceAnchor = anchors.first! as? ARFaceAnchor
////        guard faceAnchor != nil else { print("FaceAnchor not valid.."); return }
////        scnFaceGeometry.update(from: faceAnchor!.geometry)
//        scnView.scene.rootNode.addChildNode(faceNode)
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        print("AR SE NEW", anchors.count)
        guard let faceAnchor = anchors.first! as? ARFaceAnchor else {
            print("Non face anchor.")
            return
        }
        mirrors.forEach { mirror in
            mirror.didUpdate(geo: faceAnchor.geometry)
        }
        
        lastUpdate = Date()
        
//        guard let faceAnchor = anchors.first! as? ARFaceAnchor else { return }
//        scnFaceGeometry.update(from: faceAnchor.geometry)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        print("AR SE RM", anchors.count)
        mirrors.forEach { mirror in
            mirror.didRemove()
        }
    }
    
    // MARK: ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer,
                  nodeFor anchor: ARAnchor) -> SCNNode? {
        print("AR SCN NODE")
        
        guard let device = scnView.device else {
            print("AR Error: Device not found.")
            return nil
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        node = SCNNode(geometry: faceGeometry)
        
        if let image = self.image {
            addImage(image)
        } else {
            removeImage()
        }
        
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("AR SCN DID ADD")
//        mirror?.didAdd()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        print("AR SCN WILL NEW")
    }
    
    func renderer(_ renderer: SCNSceneRenderer,
                  didUpdate node: SCNNode,
                  for anchor: ARAnchor) {
        print("AR SCN DID NEW")
        
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                print("Non face anchor.")
                return
        }
        
        let geo = faceAnchor.geometry
        faceGeometry.update(from: geo)
//        DispatchQueue(label: "AR").async {
//        DispatchQueue.global(qos: .background).async {
//            self.mirror?.didUpdate(geo: geo)
//        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer,
                  didRemove node: SCNNode,
                  for anchor: ARAnchor) {
        print("AR SCN DID RM")
        self.node = nil
//        mirror?.didRemove()
    }
    
}
