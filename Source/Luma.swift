//
//  Luma.swift
//  Luma Face
//
//  Created by Hexagons on 2018-11-24.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit
import Pixels
import Pixels3D
import ARKit

class Luma: PIXDelegate, ARMirror {
    
//    static let light = Luma()
    
//    var renderCallbacks: [(pix: PIX, callback: () -> ())] = []
    
    var object3dPix: Object3DPIX!
    var finalPix: PIX!
    
    var view: UIView {
        return finalPix.view
    }
    
    init(frame: CGRect) {
        
        Pixels.main.logLevel = .debug
        Pixels.main.logAll()
        
        let res = PIX.Res(autoScaleSize: frame.size)
        
//        let polygonPix = PolygonPIX(res: res)
//        polygonPix.color = LiveColor.white.withAlpha(of: 0.25)
//        polygonPix.bgColor = .clear
        
        object3dPix = Object3DPIX(res: res)
        
        finalPix = object3dPix
        finalPix.view.frame = frame
        finalPix.view.checker = false
        
    }
    
    // MARK: - AR
    
    func activityUpdated(_ active: Bool) {
        print("LUMA ACTIVE", active)
    }
    
    func didUpdate(arFrame: ARFrame) {
        
    }
    
    func didAdd() {
        print("LUMA ADD")
    }
    
    func didUpdate(geo: ARFaceGeometry) {
        print("LUMA NEW")
        object3dPix.triangleVertices = geo.vertices.map({ v -> _3DVec in
            return _3DVec(x: CGFloat(v.x), y: CGFloat(v.y), z: CGFloat(v.z))
        })
        object3dPix.triangleUVs = geo.textureCoordinates.map({ v -> _3DUV in
            return _3DUV(u: CGFloat(v.x), v: CGFloat(v.y))
        })
        object3dPix.triangleIndices = geo.triangleIndices.map({ i -> Int in
            return Int(i)
        })
        print(geo.triangleCount, "===============", geo.triangleCount)
    }
    
    func didRemove() {
        print("LUMA RM")
    }
    
    // MARK: Luma
    
    func clear() {
        print("LUMA CLEAR")
        object3dPix.triangleVertices = []
        object3dPix.triangleUVs = []
        object3dPix.triangleIndices = []
    }
    
    // MARK: Flip
    
//    func flipY(image: UIImage, callback: @escaping (UIImage) -> ()) {
//        print("flipY >>>")
//        let imagePix = ImagePIX()
//        imagePix.name = "flipy:image"
//        imagePix.image = image
//        let flipPix = imagePix._flipY()
//        flipPix.delegate = self
//        renderCallbacks.append((pix: flipPix, callback: {
//            guard let finalImage = flipPix.renderedImage else {
//                print("flipY: no img")
//                return
//            }
//            print("flipY <<<")
//            callback(finalImage)
//        }))
//    }
    
    static func flipImage(_ image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let bitmap = UIGraphicsGetCurrentContext()!
        
//        bitmap.translateBy(x: 0, y: image.size.height / 2)
//        bitmap.scaleBy(x: 1.0, y: -1.0)
//
//        bitmap.translateBy(x: 0, y: -image.size.height / 2)
        bitmap.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: Pixels
    
    func pixResChanged(_ pix: PIX, to res: PIX.Res) {}
    
    func pixDidRender(_ pix: PIX) {
//        print("luma: render: \(pix.name ?? "-")")
//        for (i, renderCallback) in renderCallbacks.enumerated() {
//            if renderCallback.pix == pix {
//                renderCallback.callback()
//                renderCallbacks.remove(at: i)
//                break
//            }
//        }
    }
    
}
