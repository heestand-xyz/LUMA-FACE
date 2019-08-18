//
//  Sim.swift
//  Luma Face
//
//  Created by Hexagons on 2018-11-25.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import SceneKit

class Sim: ContentDelegate {
    
    let scene: SCNScene
    let view: SCNView
    
    var node: SCNNode!
    
    var wireframe: Bool = false
    
    init(frame: CGRect) {
        
        scene = SCNScene()
        view = SCNView(frame: frame)
        view.autoenablesDefaultLighting = true

        view.allowsCameraControl = true
        view.backgroundColor = .black
        view.scene = scene
        
        load()
        
        wireframeOn()
                
    }
    
    func load() {
        guard let _3d = SCNScene(named: "3D.scnassets/ARFaceGeometry.obj") else {
            fatalError("obj file not found")
        }
        guard !_3d.rootNode.childNodes.isEmpty else {
            fatalError("root not found")
        }
        node = _3d.rootNode.childNodes[0]
//        node.geometry!.firstMaterial!.isDoubleSided = true
//        node.scale = SCNVector3(1000, 1000, 1000)
//        node.geometry!.firstMaterial!.isDoubleSided = true
//        node.geometry!.firstMaterial!.emission.contents = UIColor.white
//        node.geometry!.firstMaterial!.fillMode = .lines
        scene.rootNode.addChildNode(node)
    }
    
//    func addContent() {
//        node.geometry!.firstMaterial!.fillMode = .fill
//        node.geometry!.firstMaterial!.diffuse.contents = Content.shared.finalPix.renderedTexture
//        node.geometry!.firstMaterial!.emission.contents = UIColor.black
//    }
    
//    func addImage(_ image: UIImage) {
//        node.geometry!.firstMaterial!.fillMode = .fill
////        guard let cgImage = image.cgImage else { print("bad img"); return }
////        let flippedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
//        let flippedImage = Luma.flipImage(image)
//        node.geometry!.firstMaterial!.emission.contents = flippedImage
////        Luma.light.flipY(image: image) { pixImage in }
//    }
    
//    func removeImage() {
//        node.geometry!.firstMaterial!.fillMode = .lines
//        node.geometry!.firstMaterial!.emission.contents = nil
//    }
    
    func new(texture: MTLTexture) {
        guard !wireframe else { return }
        node.geometry!.firstMaterial!.fillMode = .fill
        node.geometry!.firstMaterial!.diffuse.contents = texture
    }
    func new(image: UIImage) {
//        node.geometry!.firstMaterial!.emission.contents = image
    }
    
    func wireframeOn() {
        node.geometry!.firstMaterial!.fillMode = .lines
        node.geometry!.firstMaterial!.diffuse.contents = nil
        wireframe = true
    }
    
    func wireframeOff() {
        wireframe = false
    }
    
}
