//
//  LumaBrowseView.swift
//  Luma Browser
//
//  Created by Anton Heestand on 2019-05-09.
//  Copyright © 2019 moodelizer. All rights reserved.
//

import UIKit
import SceneKit

protocol LumaBrowseViewDelegate {
    func browsed(index: Int)
}

class LumaBrowseView: UIView, UIScrollViewDelegate {
    
    var delegate: LumaBrowseViewDelegate?
    
    let kHeight: CGFloat = 500
    let kMargin: CGFloat = 25
    let kOffsetScale: CGFloat = 0.155
    let kRotation: CGFloat = 1.0

    let scrollView: UIScrollView
    let contentView: UIView
    
    let sceneView: SCNView
    let scene: SCNScene
    
    var masksNode: SCNNode
    var maskNodes: [SCNNode]
    var maskIndex: Int = 0
    
    var wCon: NSLayoutConstraint!

    init(images: [UIImage]) {
        
        scrollView = UIScrollView()
        contentView = UIView()
        
        sceneView = SCNView()
        scene = SCNScene()
        
        masksNode = SCNNode()
        maskNodes = []

        super.init(frame: .zero)
        
        sceneView.backgroundColor = .clear
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = scene
        addSubview(sceneView)
        
        scrollView.delegate = self
        addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true
        camera.fieldOfView = 20
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0.0, 0.0, 1.0)
        scene.rootNode.addChildNode(cameraNode)
        
        scene.rootNode.addChildNode(masksNode)
        
        layout()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        contentView.addGestureRecognizer(tap)
        
        rotate(to: 0.0)
        
        loadMasks(with: images)
        
        select(index: 0)
        
    }
    
    func loadMasks(with images: [UIImage]) {
 
        for (i, image) in images.enumerated() {
            guard let _3d = SCNScene(named: "3D.scnassets/ARFaceGeometry.obj") else { fatalError("obj file not found") }
            guard !_3d.rootNode.childNodes.isEmpty else { fatalError("root not found") }
            let node = _3d.rootNode.childNodes[0]
            node.geometry!.firstMaterial!.diffuse.contents = image
            node.position = SCNVector3(CGFloat(i) * kOffsetScale, 0.0, 0.0)
            masksNode.addChildNode(node)
            maskNodes.append(node)
        }

        wCon.constant = kHeight * CGFloat(images.count)

    }
    
    func layout() {

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: kHeight).isActive = true
        
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        sceneView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sceneView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        sceneView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        scrollView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
        contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        wCon = contentView.widthAnchor.constraint(equalToConstant: 0)
        wCon.isActive = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let inset = bounds.width / 2 - kHeight / 2
        scrollView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let inset = bounds.width / 2 - kHeight / 2
        let x = scrollView.contentOffset.x + inset
        let f = x / kHeight
        let u = -f * kOffsetScale
        masksNode.position = SCNVector3(u, 0, 0)
        rotate(to: f)
    }
    
    @objc func tapped(tap: UITapGestureRecognizer) {
        let x = tap.location(in: tap.view).x
        let i = Int(x / kHeight)
        delegate?.browsed(index: i)
        select(index: i)
        animate(to: i)
    }
    
    func animate(to index: Int) {
        let inset = bounds.width / 2 - kHeight / 2
        let oldI = CGFloat(maskIndex)
        let newI = CGFloat(index)
        let oldX = scrollView.contentOffset.x
        let newX = newI * kHeight - inset
        animate(for: 0.5, ease: .easeInOut, loop: { fraction in
            let x = self.lerp(fraction, from: oldX, to: newX)
            self.scrollView.contentOffset.x = x
            let i = self.lerp(fraction, from: oldI, to: newI)
            self.rotate(to: i)
        }) {}
    }
    
    func select(index: Int) {
        maskNodes[maskIndex].scale = SCNVector3(1, 1, 1)
        maskIndex = index
        maskNodes[maskIndex].scale = SCNVector3(1.1, 1.1, 1.1)
    }
    
    func rotate(to fraction: CGFloat) {
        for (i, maskNode) in maskNodes.enumerated() {
            let f = CGFloat(i) - fraction
            maskNode.eulerAngles.y = Float(f) * Float(kRotation)
        }
    }
    
    // MARK: Helpers
    
    enum AnimationEase {
        case linear
        case easeIn
        case easeInOut
        case easeOut
    }
    func animate(for duration: CGFloat, ease: AnimationEase = .linear, loop: @escaping (CGFloat) -> (), done: @escaping () -> ()) {
        let startTime = Date()
        RunLoop.current.add(Timer(timeInterval: 1.0 / Double(UIScreen.main.maximumFramesPerSecond), repeats: true, block: { t in
            let elapsedTime = CGFloat(-startTime.timeIntervalSinceNow)
            let fraction = min(elapsedTime / duration, 1.0)
            var easeFraction = fraction
            switch ease {
            case .linear: break
            case .easeIn: easeFraction = cos(fraction * .pi / 2 - .pi) + 1
            case .easeInOut: easeFraction = cos(fraction * .pi - .pi) / 2 + 0.5
            case .easeOut: easeFraction = cos(fraction * .pi / 2 - .pi / 2)
            }
            loop(easeFraction)
            if fraction == 1.0 {
                done()
                t.invalidate()
            }
        }), forMode: .common)
    }
    
    func lerp(_ fraction: CGFloat, from: CGFloat, to: CGFloat) -> CGFloat {
        return from * (1 - fraction) + to * fraction
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
