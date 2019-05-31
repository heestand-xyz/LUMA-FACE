//
//  Content.swift
//  Luma Face
//
//  Created by Hexagons on 2019-03-21.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit
import Pixels

protocol ContentDelegate {
    func new(texture: MTLTexture)
    func new(image: UIImage)
}

class Content: PIXDelegate {
    
    var delegate: ContentDelegate?
    
    let imagePix: ImagePIX
//    let videoPix: VideoPIX
//    let mediaPix: CrossPIX
    let multPix: ColorPIX
    let finalPix: PIX
    
    var imageIndex: Int = 0
    var image: UIImage {
        return images[imageIndex]
    }
    var images: [UIImage] = [
        UIImage(named: "ARFaceGeometry_UV-Map_1k")!,
        UIImage(named: "TEXTURE copy")!,
        UIImage(named: "IMG_0025")!,
        UIImage(named: "IMG_0069")!,
        UIImage(named: "IMG_1585")!,
        UIImage(named: "MASTER-1_00000")!,
        UIImage(named: "MASTER-2 (0-00-00-00)")!,
        UIImage(named: "MASTER-2_00000")!,
        UIImage(named: "test_2")!,
        UIImage(named: "test_3")!,
        UIImage(named: "test_fade")!,
        UIImage(named: "test")!,
        UIImage(named: "with_glow_00000")!
    ]
    
    var videoIndex: Int = 0
    var video: URL {
        return videos[videoIndex]
    }
    var videos: [URL] = [
//        Bundle.main.url(forResource: "lines", withExtension: "mp4")!
        Bundle.main.url(forResource: "screen", withExtension: "mov")!
    ]
    
    init() {
        
        imagePix = ImagePIX()
//        videoPix = VideoPIX()
//        mediaPix = CrossPIX()
//        mediaPix.fraction = 0.0
//        mediaPix.inPixA = imagePix
//        mediaPix.inPixB = videoPix
        multPix = ColorPIX(res: ._2048)
        finalPix = multPix * imagePix
        
        loadNextImage()
//        loadNextVideo()
//        videoPix.pause()

        finalPix.delegate = self
        
    }
    
    func loadNextImage() {
        imagePix.image = image
        imageIndex = imageIndex + 1 % images.count
//        mediaPix.fraction = 0.0
    }
    
    func loadExternal(image: UIImage) {
        imagePix.image = image
//        mediaPix.fraction = 0.0
    }
    
//    func loadNextVideo() {
//        videoPix.load(url: video)
//        videoPix.play()
//        videoIndex = videoIndex + 1 % videos.count
////        mediaPix.fraction = 1.0
//    }
    
    func pixResChanged(_ pix: PIX, to res: PIX.Res) {}
    
    func pixDidRender(_ pix: PIX) {
        guard let texture = pix.renderedTexture else { return }
        delegate?.new(texture: texture)
        guard let image = pix.renderedImage else { return }
        delegate?.new(image: image)
    }
    
    func mult(color: LiveColor) {
        multPix.color = color
    }
    
}
