//
//  Sim.swift
//  Luma Face
//
//  Created by Hexagons on 2018-11-25.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import SceneKit

class Sim {
    
    let scene: SCNScene
    let view: SCNView
    
    var node: SCNNode!
    
    init(frame: CGRect) {
        
        scene = SCNScene()
        view = SCNView(frame: frame)
        
        
        view.allowsCameraControl = true
        view.backgroundColor = .black
        view.scene = scene
        
        load()
        
    }
    
    func load() {
        guard let _3d = SCNScene(named: "3D.scnassets/ARFaceGeometry.obj") else {
            fatalError("obj file not found")
        }
        guard !_3d.rootNode.childNodes.isEmpty else {
            fatalError("root not found")
        }
        node = _3d.rootNode.childNodes[0]
        node.geometry!.firstMaterial!.fillMode = .lines
        scene.rootNode.addChildNode(node)
    }
    
    func addImage(_ image: UIImage) {
        node.geometry!.firstMaterial!.fillMode = .fill
//        guard let cgImage = image.cgImage else { print("bad img"); return }
//        let flippedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
        let flippedImage = Luma.light.flipImage(image)
        self.node.geometry!.firstMaterial!.diffuse.contents = flippedImage
//        Luma.light.flipY(image: image) { pixImage in }
    }
    
    func removeImage() {
        node.geometry!.firstMaterial!.fillMode = .lines
        node.geometry!.firstMaterial!.diffuse.contents = nil
    }
    
}
