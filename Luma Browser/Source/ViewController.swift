//
//  ViewController.swift
//  Luma Browser
//
//  Created by Hexagons on 2019-05-31.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var lumaBrowseView: LumaBrowseView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let contentImages = getContentImages()
        
        lumaBrowseView = LumaBrowseView(images: contentImages)
        view.addSubview(lumaBrowseView)
        
    }
    
    func getContentImages() -> [UIImage] {
        let documentsURL = Bundle.main.resourceURL!
        let fileURLs = try! FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
        var urls: [URL] = []
        for fileURL in fileURLs {
            if ["png", "jpg"].contains(fileURL.pathExtension) {
                print("FILE:", fileURL)
                urls.append(fileURL)
            }
        }
        var images: [UIImage] = []
        for url in urls {
            guard let data = try? Data(contentsOf: url) else { continue }
            guard let image = UIImage(data: data) else { continue }
            images.append(reFrame(image)!)
        }
        return images
    }
    
    func reFrame(_ image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let bitmap = UIGraphicsGetCurrentContext()!
        bitmap.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        lumaBrowseView.translatesAutoresizingMaskIntoConstraints = false
        lumaBrowseView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        lumaBrowseView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        lumaBrowseView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        lumaBrowseView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
    }

}

