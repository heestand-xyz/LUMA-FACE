//
//  AR.swift
//  Luma Face
//
//  Created by Hexagons on 2018-11-24.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import ARKit

class AR: NSObject, /*ARSessionDelegate,*/ ARSCNViewDelegate {
    
    static var isSupported: Bool {
        return ARFaceTrackingConfiguration.isSupported
    }
    
    let view: UIView
    
    let session: ARSession
    let scnView: ARSCNView
    
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

    }
    
    func run() {
        let config = ARFaceTrackingConfiguration()
        config.isLightEstimationEnabled = false
        session.run(config)
    }
    
    func pause() {
        session.pause()
    }
    
    // MARK: AR Delegation
    
//    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
////        guard faceAnchor == nil else { print("FACE too late.."); return }
////        faceAnchor = anchors.first! as? ARFaceAnchor
////        guard faceAnchor != nil else { print("FaceAnchor not valid.."); return }
////        scnFaceGeometry.update(from: faceAnchor!.geometry)
//        scnView.scene.rootNode.addChildNode(faceNode)
//    }
//
//    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
//        guard let faceAnchor = anchors.first! as? ARFaceAnchor else { return }
//        scnFaceGeometry.update(from: faceAnchor.geometry)
//    }
    
    func renderer(_ renderer: SCNSceneRenderer,
                  nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let device = scnView.device else {
            print("AR Error: Device not found.")
            return nil
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)
        node.geometry!.firstMaterial!.fillMode = .lines
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer,
                  didUpdate node: SCNNode,
                  for anchor: ARAnchor) {
        
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                return
        }
        
        faceGeometry.update(from: faceAnchor.geometry)
    }
    
}
