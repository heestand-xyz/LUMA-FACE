//
//  Content.swift
//  Luma Face
//
//  Created by Hexagons on 2019-03-21.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit
import PixelKit

protocol ContentDelegate {
    func new(texture: MTLTexture)
    func new(image: UIImage)
}

class Content: PIXDelegate {
    
    var delegate: ContentDelegate?

//    let imagePix: ImagePIX
//    let multPix: ColorPIX
//    let bgPix: ColorPIX
//    let finalPix: PIX
    
    var calibrationImage: UIImage!
    
    var imageIndex: Int = 0
    var image: UIImage {
        return flip(image: images[imageIndex])!
    }
    var images: [UIImage]
    
//    var videoIndex: Int = 0
//    var video: URL {
//        return videos[videoIndex]
//    }
//    var videos: [URL] = [
////        Bundle.main.url(forResource: "lines", withExtension: "mp4")!
//        Bundle.main.url(forResource: "screen", withExtension: "mov")!
//    ]
    
    init() {
        
        images = FileLoader.getContentImages()
        
//        imagePix = ImagePIX()
//        multPix = ColorPIX(res: ._2048)
//        bgPix = ColorPIX(res: ._2048)
//        bgPix.color = .black
//        finalPix = bgPix & (multPix * imagePix._flipY()._lumaToAlpha())
        
        loadNextImage()

//        finalPix.delegate = self
        
        calibrationImage = UIImage(named: "calibration_blue")!
        
    }
    
    func flip(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        guard let context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: 4 * Int(image.size.width), space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -image.size.height)
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        guard let image = context.makeImage() else { return nil }
        return UIImage(cgImage: image)
    }
    
    func loadImageAt(index: Int) {
        imageIndex = index
//        imagePix.image = image
        delegate?.new(image: image)
    }
    
    func loadNextImage() {
        imageIndex = (imageIndex + 1) % images.count
//        imagePix.image = image
        delegate?.new(image: image)
    }
    
    func loadExternal(image: UIImage) {
//        imagePix.image = image
        delegate?.new(image: image)
    }
    
    func loadCalibration() {
//        imagePix.image = calibrationImage
//        mult(color: .blue)
        delegate?.new(image: calibrationImage)
    }
    
    func loadLastImage() {
//        imagePix.image = image
        delegate?.new(image: image)
    }
    
    func pixResChanged(_ pix: PIX, to res: PIX.Res) {}
    
    func pixDidRender(_ pix: PIX) {
        guard let texture = pix.renderedTexture else { return }
        delegate?.new(texture: texture)
//        guard let image = pix.renderedImage else { return }
//        delegate?.new(image: image)
    }
    
    func mult(color: LiveColor) {
//        multPix.color = color
    }
    
    func bg(color: LiveColor) {
//        bgPix.color = color
    }
    
}
