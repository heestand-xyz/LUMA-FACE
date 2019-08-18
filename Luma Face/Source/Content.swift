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

    let imagePix: ImagePIX
//    let videoPix: VideoPIX
//    let mediaPix: CrossPIX
    let multPix: ColorPIX
    let bgPix: ColorPIX
    let finalPix: PIX
    
    var imageIndex: Int = 0
    var image: UIImage {
        return images[imageIndex]
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
        
        imagePix = ImagePIX()
//        videoPix = VideoPIX()
//        mediaPix = CrossPIX()
//        mediaPix.fraction = 0.0
//        mediaPix.inPixA = imagePix
//        mediaPix.inPixB = videoPix
        multPix = ColorPIX(res: ._2048)
        bgPix = ColorPIX(res: ._2048)
        bgPix.color = .black
        finalPix = bgPix & (multPix * imagePix._flipY()._lumaToAlpha())
        
        loadNextImage()
//        loadNextVideo()
//        videoPix.pause()

        finalPix.delegate = self
        
    }
    
    func loadImageAt(index: Int) {
        imageIndex = index
        imagePix.image = image
    }
    
    func loadNextImage() {
        imagePix.image = image
        imageIndex = (imageIndex + 1) % images.count
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
//        guard let image = pix.renderedImage else { return }
//        delegate?.new(image: image)
    }
    
    func mult(color: LiveColor) {
        multPix.color = color
    }
    
    func bg(color: LiveColor) {
        bgPix.color = color
    }
    
}
