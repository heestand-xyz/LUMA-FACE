//
//  LiveCamView.swift
//  Luma Face
//
//  Created by Hexagons on 2019-08-09.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit
import PixelKit

class LiveCamView: UIView {
    
    var cameraPix: CameraPIX!
    var reorderPix: ReorderPIX!
    var finalPix: PIX!
    
    override init(frame: CGRect) {
     
        super.init(frame: frame)
        
        cameraPix = CameraPIX()
        
        reorderPix = ReorderPIX()
        reorderPix.inPixA = cameraPix
        reorderPix.inPixB = cameraPix
        
        finalPix = reorderPix
        finalPix.view.frame = frame
        addSubview(finalPix.view)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
