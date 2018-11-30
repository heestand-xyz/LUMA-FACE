//
//  Face.swift
//  Luma Face
//
//  Created by Hexagons on 2018-11-24.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import ARKit

class Face/*: ARMirror*/ {
    
    let scene: SCNScene
    let view: SCNView
    
    var node: SCNNode?
    
    init(frame: CGRect) {
        
        scene = SCNScene()
        view = SCNView(frame: frame)
        
        
        view.allowsCameraControl = true
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        view.scene = scene
        
    }
    
//    func didSetup(cam: SCNCamera) {
//        print("CAM")
//        scene.rootNode.camera = cam
//    }
//
//    func didAdd(node: SCNNode) {
//        print("NODE")
//        self.node = node
//        scene.rootNode.addChildNode(node)
//    }
//
//    func didUpdate(geo: ARFaceGeometry) {
//        print("GEO")
//        guard let faceGeometry = self.node?.geometry as? ARSCNFaceGeometry else {
//            print("Face Mirror Failed.")
//            return
//        }
//        faceGeometry.update(from: geo)
//    }
    
}
