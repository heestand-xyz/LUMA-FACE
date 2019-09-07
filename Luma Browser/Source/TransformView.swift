//
//  TransformView.swift
//  Luma Browser
//
//  Created by Hexagons on 2019-09-07.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit

protocol TransformDelegate {
    func transform(position: CGPoint, zoom: CGFloat)
}

class TransformView: UIView {
    
    var delegate: TransformDelegate?

    let length: CGFloat = 100
    
    var zoom: CGFloat = 1.0
    var position: CGPoint = .zero
    var _zoom: CGFloat?
    var _position: CGPoint?
    
    let indicatorView: UIView
    
    var indicatorCenterXConstraint: NSLayoutConstraint!
    var indicatorCenterYConstraint: NSLayoutConstraint!
    var indicatorWidthConstraint: NSLayoutConstraint!
    var indicatorHeightConstraint: NSLayoutConstraint!
    
    init() {
        
        indicatorView = UIView()
        
        super.init(frame: .zero)
        
        addSubview(indicatorView)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(reset))
        addGestureRecognizer(longPress)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(zoomFaceMask))
        addGestureRecognizer(pinch)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(moveFaceMask))
        addGestureRecognizer(pan)
        
        style()
        layout()
        
    }
    
    func style() {
        
        backgroundColor = .black
        
        indicatorView.layer.borderColor = UIColor.white.cgColor
        indicatorView.layer.borderWidth = 5
        indicatorView.layer.cornerRadius = 10
        
    }
    
    func layout() {
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorCenterXConstraint = indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor)
        indicatorCenterXConstraint.isActive = true
        indicatorCenterYConstraint = indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        indicatorCenterYConstraint.isActive = true
        indicatorWidthConstraint = indicatorView.widthAnchor.constraint(equalToConstant: length)
        indicatorWidthConstraint.isActive = true
        indicatorHeightConstraint = indicatorView.heightAnchor.constraint(equalToConstant: length)
        indicatorHeightConstraint.isActive = true
        
    }
    
    @objc func reset(longPess: UILongPressGestureRecognizer) {
        guard longPess.state == .recognized else { return }
        let alert = UIAlertController(title: "Trasform", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reset", style: .default, handler: { _ in
            self.position = .zero
            self.zoom = 1.0
            self.move()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        let vc = UIApplication.shared.keyWindow!.rootViewController as! ViewController
        vc.present(alert, animated: true, completion: nil)
    }
    
    @objc func zoomFaceMask(pinch: UIPinchGestureRecognizer) {
        switch pinch.state {
        case .began:
            _zoom = zoom
        case .changed:
            zoom = _zoom! * pinch.scale
            move()
        case .ended, .cancelled:
            _zoom = nil
        default: break
        }
    }
    
    @objc func moveFaceMask(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            _position = position
        case .changed:
            position = CGPoint(
                x: _position!.x + pan.translation(in: self).x,
                y: _position!.y + pan.translation(in: self).y)
            move()
        case .ended, .cancelled:
            _position = nil
        default: break
        }
    }
    
    func move() {
        indicatorCenterXConstraint.constant = position.x
        indicatorCenterYConstraint.constant = position.y
        indicatorWidthConstraint.constant = length * zoom
        indicatorHeightConstraint.constant = length * zoom
        delegate?.transform(position: position, zoom: zoom)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
