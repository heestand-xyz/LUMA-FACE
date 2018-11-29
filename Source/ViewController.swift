//
//  ViewController.swift
//  Luma Face
//
//  Created by Hexagons on 2018-11-24.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var luma: Luma!
    
    var ar: AR?
//    var face: Face?
    var sim: Sim?
    
    var flipped: Bool = false
    var zoom: CGFloat = 1.0
    var position: CGPoint = .zero
    var _zoom: CGFloat?
    var _position: CGPoint?
    
    var indiBottomLeftView: UIView!
    var indiBottomRightView: UIView!
    var indiTopLeftView: UIView!
    var indiTopRightView: UIView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        
        luma = Luma(frame: view.bounds)
        
        if AR.isSupported {
            ar = AR(frame: view.bounds)
//            face = Face(frame: view.bounds)
        } else {
            sim = Sim(frame: view.bounds)
        }
        
        
        super.viewDidLoad()
        
        
        if AR.isSupported {
//            ar!.mirror = face
//            ar!.view.alpha = 0.1
            ar!.view.alpha = 0.25
            view.addSubview(ar!.view)
//            view.addSubview(face!.view)
        } else {
            view.addSubview(sim!.view)
        }
        
        if AR.isSupported {
            ar!.mirror = luma
        }
        view.addSubview(luma.view)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addFaceMask))
        view.addGestureRecognizer(longPress)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(zoomFaceMask))
        view.addGestureRecognizer(pinch)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(flipFaceMask))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(moveFaceMask))
        view.addGestureRecognizer(pan)
        
        indiBottomLeftView = UIView(frame: CGRect(x: 10, y: view.bounds.height - 20, width: 10, height: 10))
        indiBottomRightView = UIView(frame: CGRect(x: view.bounds.width - 20, y: view.bounds.height - 20, width: 10, height: 10))
        indiTopLeftView = UIView(frame: CGRect(x: 10, y: 10, width: 10, height: 10))
        indiTopRightView = UIView(frame: CGRect(x: view.bounds.width - 20, y: 10, width: 10, height: 10))
        indiBottomLeftView.layer.cornerRadius = 5
        indiBottomRightView.layer.cornerRadius = 5
        indiTopLeftView.layer.cornerRadius = 5
        indiTopRightView.layer.cornerRadius = 5
        indiBottomLeftView.backgroundColor = .darkGray
        indiBottomRightView.backgroundColor = .darkGray
        indiTopLeftView.backgroundColor = .darkGray
        indiTopRightView.backgroundColor = .darkGray
        view.addSubview(indiBottomLeftView)
        view.addSubview(indiBottomRightView)
        view.addSubview(indiTopLeftView)
        view.addSubview(indiTopRightView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        checkBattery()
        
        indiMaskReset()
        
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
    
    // MARK: Battery
    
    @objc func appWillEnterForeground() {
        checkBattery()
    }
    
    @objc func batteryLevelDidChange() {
        checkBattery()
    }
    
    func checkBattery() {
        let battery = CGFloat(UIDevice.current.batteryLevel)
        guard battery != -1 else { return }
        indiTopRightView.backgroundColor = battery > 0.5 ? .white : .clear
//        indiTopRightView.backgroundColor = UIColor(displayP3Red: 1 - max(0, battery * 2 - 1), green: min(1, battery * 2), blue: 0.0, alpha: 1.0)
    }
    
    // MARK: Face Mask
    
    @objc func addFaceMask(longPess: UILongPressGestureRecognizer) {
        guard longPess.state == .began else { return }
        
        ViewAssistant.shared.alert("Luma Face", "AR\(AR.isSupported ? "" : " not") supported.", actions: [
            ViewAssistant.AlertAction(title: "Load Texture", style: .default, handeler: { _ in
                
                FileAssistant.shared.media_picker_assistant.pickMedia(media_type: .photo, pickedImage: { image in
                    DispatchQueue.main.async {
                        if AR.isSupported {
                            self.ar!.addImage(image)
                        } else {
                            self.sim!.addImage(image)
                        }
                    }
                })
                
            }),
            ViewAssistant.AlertAction(title: "Remove Texture", style: .destructive, handeler: { _ in
                if AR.isSupported {
                    self.ar!.removeImage()
                } else {
                    self.sim!.removeImage()
                }
            }),
            ViewAssistant.AlertAction(title: "Reset  Transform", style: .destructive, handeler: { _ in
                self.resetMask()
            })
        ])
        
    }
    
    @objc func zoomFaceMask(pinch: UIPinchGestureRecognizer) {
        switch pinch.state {
        case .began:
            _zoom = zoom
        case .changed:
            zoom = _zoom! * pinch.scale
        case .ended, .cancelled:
            _zoom = nil
        default: break
        }
        moveMask()
    }
    
    @objc func flipFaceMask(tap: UITapGestureRecognizer) {
        flipped = !flipped
        moveMask()
    }
    
    @objc func moveFaceMask(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            _position = position
        case .changed:
            position = CGPoint(
                x: _position!.x + pan.translation(in: view).x,
                y: _position!.y + pan.translation(in: view).y)
        case .ended, .cancelled:
            _position = nil
        default: break
        }
        moveMask()
    }
    
    func moveMask() {
        if AR.isSupported {
            let flip: CGFloat = flipped ? -1.0 : 1.0
            ar!.view.transform = CGAffineTransform.identity
                .translatedBy(x: position.x, y: position.y)
                .scaledBy(x: zoom * flip, y: zoom)
            indiBottomLeftView.backgroundColor = .clear
        }
    }
    
    func resetMask() {
        flipped = false
        zoom = 1.0
        position = .zero
        moveMask()
        indiMaskReset()
    }
    
    func indiMaskReset() {
        indiBottomLeftView.backgroundColor = .white
    }

}
