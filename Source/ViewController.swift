//
//  ViewController.swift
//  Luma Face
//
//  Created by Hexagons on 2018-11-24.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import ARKit
import Pixels

class ViewController: UIViewController, ARMirror, PixelsDelegate {
    
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
    
    var fpsLabel: UILabel!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        
        Pixels.main.delegate = self
        
        luma = Luma(frame: view.bounds)
        
        if AR.isSupported {
            ar = AR(frame: view.bounds)
//            face = Face(frame: view.bounds)
        } else {
            sim = Sim(frame: view.bounds)
        }
        
        
        super.viewDidLoad()
        
        
        if AR.isSupported {
            ar!.mirrors = [self, luma]
            ar!.view.alpha = 0
            view.addSubview(ar!.view)
        } else {
            view.addSubview(sim!.view)
        }
        
        luma.view.alpha = 0.1
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
        indiBottomLeftView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        indiBottomRightView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        indiTopLeftView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        indiTopRightView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        view.addSubview(indiBottomLeftView)
        view.addSubview(indiBottomRightView)
        view.addSubview(indiTopLeftView)
        view.addSubview(indiTopRightView)
        
        fpsLabel = UILabel(frame: CGRect(x: view.bounds.width / 2 - 50, y: view.bounds.height - 20, width: 100, height: 20))
        fpsLabel.text = "# fps"
        fpsLabel.textColor = .white
        fpsLabel.textAlignment = .center
        fpsLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .heavy)
        view.addSubview(fpsLabel)
        
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
    
    // MARK: - Pixels
    
    func pixelsFrameLoop() {
        fpsLabel.text = "\(Pixels.main.fps) fps"
    }
    
    // MARK: - AR
    
    func activityUpdated(_ active: Bool) {
        indiTopLeftView.backgroundColor = active ? .white : UIColor(white: 0.1, alpha: 1.0)
        UIView.animate(withDuration: 0.5, animations: {
            self.luma.view.alpha = active ? 1.0 : 0.1
        }) { _ in
            if !active {
                self.luma.clear()
            }
        }
    }
    
    func didUpdate(arFrame: ARFrame) {}
    
    func didAdd() {}
    
    func didUpdate(geo: ARFaceGeometry) {}
    
    func didRemove() {}
    
    
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
            indiBottomLeftView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
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
        indiTopRightView.backgroundColor = battery > 0.5 ? .white : UIColor(white: 0.1, alpha: 1.0)
        //        indiTopRightView.backgroundColor = UIColor(displayP3Red: 1 - max(0, battery * 2 - 1), green: min(1, battery * 2), blue: 0.0, alpha: 1.0)
    }
    
}
