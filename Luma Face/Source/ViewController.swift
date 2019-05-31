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
    
    var content: Content!
    
//    var luma: Luma!
    
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
    
    var airView: UIView!
    var airPlayPIX: AirPlayPIX!
    
    var rBtn: UIButton!
    var gBtn: UIButton!
    var bBtn: UIButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        
        Pixels.main.delegate = self
        Pixels.main.logLoopLimitActive = false
        
        content = Content()
        
        airView = UIView(frame: CGRect(x: 0, y: 0, width: 1920, height: 1080))
        airView.backgroundColor = .black
        airView.transform = airView.transform.scaledBy(x: -1, y: 1)
        
//        luma = Luma(frame: view.bounds)
        
        if AR.isSupported {
            ar = AR(frame: airView.bounds)
//            face = Face(frame: view.bounds)
            content.delegate = ar
        } else {
            sim = Sim(frame: airView.bounds)
            content.delegate = sim
        }
        
        
        super.viewDidLoad()
        
        
        if AR.isSupported {
            ar!.mirrors = [self/*, luma*/]
//            ar!.view.alpha = 0
            airView.addSubview(ar!.view)
        } else {
            airView.addSubview(sim!.view)
        }
        
//        luma.view.alpha = 0.1
//        view.addSubview(luma.view)
        
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
        
        rBtn = UIButton()
        rBtn.backgroundColor = .red
        rBtn.tag = 1
        rBtn.addTarget(self, action: #selector(rgbOnOff), for: .touchUpInside)
        view.addSubview(rBtn)
        gBtn = UIButton()
        gBtn.backgroundColor = .green
        gBtn.tag = 2
        gBtn.addTarget(self, action: #selector(rgbOnOff), for: .touchUpInside)
        view.addSubview(gBtn)
        bBtn = UIButton()
        bBtn.backgroundColor = .blue
        bBtn.tag = 3
        bBtn.addTarget(self, action: #selector(rgbOnOff), for: .touchUpInside)
        view.addSubview(bBtn)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        checkBattery()
        
        indiMaskReset()
        
        let bgPix = ColorPIX(res: ._1080p)
        bgPix.color = .black
        
        airPlayPIX = AirPlayPIX()
        airPlayPIX.inPix = bgPix
        airPlayPIX.view.addSubview(airView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AR.isSupported {
            ar!.run()
        }
        
        rBtn.translatesAutoresizingMaskIntoConstraints = false
        rBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        rBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -30).isActive = true
        rBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        rBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        gBtn.translatesAutoresizingMaskIntoConstraints = false
        gBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        gBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        gBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        gBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        bBtn.translatesAutoresizingMaskIntoConstraints = false
        bBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        bBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 30).isActive = true
        bBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        bBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
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
//        UIView.animate(withDuration: 0.5, animations: {
//            self.luma.view.alpha = active ? 1.0 : 0.1
//        }) { _ in
//            if !active {
//                self.luma.clear()
//            }
//        }
    }
    
    func didUpdate(arFrame: ARFrame) {}
    
    func didAdd() {}
    
    func didUpdate(geo: ARFaceGeometry) {}
    
    func didRemove() {}
    
    // MARK: RGB
    
    @objc func rgbOnOff(btn: UIButton) {
        btn.tag = -btn.tag
        let r = rBtn.tag > 0 ? 1 : 0
        let g = gBtn.tag > 0 ? 1 : 0
        let b = bBtn.tag > 0 ? 1 : 0
        btn.alpha = btn.tag > 0 ? 1.0 : 1 / 3
        let c = LiveColor(r: LiveFloat(r), g: LiveFloat(g), b: LiveFloat(b))
        content.mult(color: c)
    }
    
    // MARK: Face Mask
    
    @objc func addFaceMask(longPess: UILongPressGestureRecognizer) {
        guard longPess.state == .began else { return }
        ViewAssistant.shared.alert("Luma Face", "AR\(AR.isSupported ? "" : " not") supported.", actions: [
            ViewAssistant.AlertAction(title: "Next Image", style: .default, handeler: { _ in
                self.content.loadNextImage()
            }),
//            ViewAssistant.AlertAction(title: "Next Video", style: .default, handeler: { _ in
//                self.content.loadNextVideo()
//            }),
            ViewAssistant.AlertAction(title: "Load Image Texture", style: .default, handeler: { _ in
                FileAssistant.shared.media_picker_assistant.pickMedia(media_type: .photo, pickedImage: { image in
                    DispatchQueue.main.async {
//                        if AR.isSupported {
//                            self.ar!.addImage(image)
//                        } else {
//                            self.sim!.addImage(image)
//                        }
                        self.content.loadExternal(image: image)
                    }
                })
            }),
//            ViewAssistant.AlertAction(title: "Load PIX A Texture", style: .default, handeler: { _ in
//                if AR.isSupported {
//                    self.ar!.addPIXA()
//                }
//            }),
//            ViewAssistant.AlertAction(title: "Load PIX B Texture", style: .default, handeler: { _ in
//                if AR.isSupported {
//                    self.ar!.addPIXB()
//                }
//            }),
//            ViewAssistant.AlertAction(title: "Remove Texture", style: .destructive, handeler: { _ in
//                if AR.isSupported {
//                    self.ar!.removeImage()
//                } else {
//                    self.sim!.removeImage()
//                }
//            }),
            ViewAssistant.AlertAction(title: "Reset Transform", style: .destructive, handeler: { _ in
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
