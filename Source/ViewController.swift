//
//  ViewController.swift
//  Luma Face
//
//  Created by Hexagons on 2018-11-24.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit
import Pixels

class ViewController: UIViewController {

    var ar: AR?
    
    var finalPix: PIX!
    
    override func viewDidLoad() {
        
        if AR.isSupported {
            ar = AR(frame: view.bounds)
        }
        
        super.viewDidLoad()
        
        if AR.isSupported {
            view.addSubview(ar!.view)
        } else {
            view.backgroundColor = .blue
        }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addFaceMask))
        view.addGestureRecognizer(longPress)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AR.isSupported {
            ar!.run()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if AR.isSupported {
            ar!.pause()
        }
    }
    
    @objc func addFaceMask(longPess: UILongPressGestureRecognizer) {
        guard longPess.state == .began else { return }
        print(": D")
    }

}

