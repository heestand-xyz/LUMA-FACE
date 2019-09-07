//
//  FileLoader.swift
//  Luma Face
//
//  Created by Hexagons on 2019-06-30.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit

class FileLoader {
    
    static func getContentImages() -> [UIImage] {
        let documentsURL = Bundle.main.resourceURL!
        let fileURLs = try! FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
        var urls: [URL] = []
        for fileURL in fileURLs {
            if ["png", "jpg", "PNG", "JPG"].contains(fileURL.pathExtension) {
                urls.append(fileURL)
            }
        }
        var images: [UIImage] = []
        for url in urls {
            guard !url.path.contains("AppIcon") else { continue }
            guard let data = try? Data(contentsOf: url) else { continue }
            guard let image = UIImage(data: data) else { continue }
            images.append(FileLoader.reFrame(image)!)
        }
        print("IMGs:", images.count)
        return images
    }
    
    static func reFrame(_ image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let bitmap = UIGraphicsGetCurrentContext()!
        bitmap.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
