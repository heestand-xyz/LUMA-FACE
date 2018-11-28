//
//  AR.swift
//  Luma Face
//
//  Created by Hexagons on 2018-11-24.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import ARKit

protocol ARMirror {
//    func didSetup(cam: SCNCamera)
//    func didAdd(node: SCNNode)
    func didUpdate(geo: ARFaceGeometry)
}

class AR: NSObject, /*ARSessionDelegate,*/ ARSCNViewDelegate {
    
    var mirror: ARMirror?
    
    static var isSupported: Bool {
        return ARFaceTrackingConfiguration.isSupported
    }
    
    let view: UIView
    
    let session: ARSession
    let scnView: ARSCNView
    
    var lowFps: Bool = false
    
    var node: SCNNode?
    
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
        
        
//        session.delegate = self
        
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
    }
    
    func removeImage() {
        guard node != nil else { return }
        node!.geometry!.firstMaterial!.fillMode = .lines
        node!.geometry!.firstMaterial!.diffuse.contents = nil
    }
    
    // MARK: AR Delegation
    
//    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
////        guard faceAnchor == nil else { print("FACE too late.."); return }
////        faceAnchor = anchors.first! as? ARFaceAnchor
////        guard faceAnchor != nil else { print("FaceAnchor not valid.."); return }
////        scnFaceGeometry.update(from: faceAnchor!.geometry)
//        scnView.scene.rootNode.addChildNode(faceNode)
//    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
//        guard let faceAnchor = anchors.first! as? ARFaceAnchor else { return }
//        scnFaceGeometry.update(from: faceAnchor.geometry)
    }
    
    func renderer(_ renderer: SCNSceneRenderer,
                  nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = scnView.device else {
            print("AR Error: Device not found.")
            return nil
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        node = SCNNode(geometry: faceGeometry)
        node!.geometry!.firstMaterial!.fillMode = .lines
        
//        mirror?.didAdd(node: node!)
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer,
                  didUpdate node: SCNNode,
                  for anchor: ARAnchor) {
        
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                return
        }
        
        let geo = faceAnchor.geometry
        faceGeometry.update(from: geo)
        mirror?.didUpdate(geo: geo)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        self.node = nil
    }
    
}
