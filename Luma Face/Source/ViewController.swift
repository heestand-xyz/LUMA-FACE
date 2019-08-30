//
//  ViewController.swift
//  Luma Face
//
//  Created by Hexagons on 2018-11-24.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import ARKit
import PixelKit

class ViewController: UIViewController, ARMirror, PixelDelegate {
    
    var content: Content!
    
//    var luma: Luma!
    
    var ar: AR?
//    var face: Face?
    var sim: Sim?
    
    enum Display {
        case iPhone
        case projector
    }
    let display: Display = .iPhone
    
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
    var rBgBtn: UIButton!
    var gBgBtn: UIButton!
    var bBgBtn: UIButton!
    
    var oscServerButton: UIButton!
    var oscClientButton: UIButton!

    var canAR: Bool {
        return AR.isSupported
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        
        PixelKit.main.delegate = self
        PixelKit.main.logLoopLimitActive = false
        
        content = Content()
        
        airView = UIView(frame: CGRect(x: 0, y: 0, width: 1920, height: 1080))
        airView.backgroundColor = .black
        airView.transform = airView.transform.scaledBy(x: -1, y: 1)
        
//        luma = Luma(frame: view.bounds)
        
        if canAR {
            ar = AR(frame: display == .projector ? airView.bounds : view.bounds)
//            face = Face(frame: view.bounds)
            content.delegate = ar
        } else {
            sim = Sim(frame: /*airView.*/view.bounds)
            content.delegate = sim
        }
        
        
        super.viewDidLoad()
        
        
        if canAR {
            ar!.mirrors = [self/*, luma*/]
//            ar!.view.alpha = 0
            switch display {
            case .iPhone:
                view.addSubview(ar!.view)
            case .projector:
                airView.addSubview(ar!.view)
            }
        } else {
            /*airView.*/view.addSubview(sim!.view)
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
        
        rBgBtn = UIButton()
        rBgBtn.backgroundColor = .red
        rBgBtn.tag = -1
        rBgBtn.alpha = 1 / 3
        rBgBtn.addTarget(self, action: #selector(rgbBgOnOff), for: .touchUpInside)
        view.addSubview(rBgBtn)
        gBgBtn = UIButton()
        gBgBtn.backgroundColor = .green
        gBgBtn.tag = -2
        gBgBtn.alpha = 1 / 3
        gBgBtn.addTarget(self, action: #selector(rgbBgOnOff), for: .touchUpInside)
        view.addSubview(gBgBtn)
        bBgBtn = UIButton()
        bBgBtn.backgroundColor = .blue
        bBgBtn.tag = -3
        bBgBtn.alpha = 1 / 3
        bBgBtn.addTarget(self, action: #selector(rgbBgOnOff), for: .touchUpInside)
        view.addSubview(bBgBtn)
        
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
        
        
        let local_ip = LFIP.getAddress()
        let local_port = LFOSCServer.main.port
        
        oscServerButton = UIButton(type: .system)
        oscServerButton.isEnabled = false
        oscServerButton.tintColor = .white
        oscServerButton.setTitle("Server: \(local_ip):\(local_port)", for: .normal)
        view.addSubview(oscServerButton)
        
        LFOSCServer.main.listen(to: "ping") { _ in
            print("PING")
            let alert = UIAlertController(title: "OSC Ping", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        LFOSCServer.main.listen(to: "image-index") { index in
            if self.canAR {
                self.ar?.wireframeOff()
            } else {
                self.sim?.wireframeOff()
            }
            self.content.loadImageAt(index: index as! Int)
        }
        
        
        let remote_ip = UserDefaults.standard.string(forKey: "osc-ip") ?? "0.0.0.0"
        let remote_port = UserDefaults.standard.integer(forKey: "osc-port")
        LFOSCClient.main.setup(ip: remote_ip, port: remote_port)
        
        oscClientButton = UIButton(type: .system)
        oscClientButton.tintColor = .white
        oscClientButton.setTitle("Client: \(remote_ip):\(remote_port)", for: .normal)
        oscClientButton.addTarget(self, action: #selector(oscSetup), for: .touchUpInside)
        view.addSubview(oscClientButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if canAR {
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
        
        
        rBgBtn.translatesAutoresizingMaskIntoConstraints = false
        rBgBtn.topAnchor.constraint(equalTo: rBtn.bottomAnchor).isActive = true
        rBgBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -30).isActive = true
        rBgBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        rBgBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        gBgBtn.translatesAutoresizingMaskIntoConstraints = false
        gBgBtn.topAnchor.constraint(equalTo: gBtn.bottomAnchor).isActive = true
        gBgBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        gBgBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        gBgBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        bBgBtn.translatesAutoresizingMaskIntoConstraints = false
        bBgBtn.topAnchor.constraint(equalTo: bBtn.bottomAnchor).isActive = true
        bBgBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 30).isActive = true
        bBgBtn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        bBgBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        oscServerButton.translatesAutoresizingMaskIntoConstraints = false
        oscServerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        oscServerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        
        oscClientButton.translatesAutoresizingMaskIntoConstraints = false
        oscClientButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        oscClientButton.bottomAnchor.constraint(equalTo: oscServerButton.topAnchor, constant: -10).isActive = true
        
    }
    
    @objc func oscSetup() {
        let ip = UserDefaults.standard.string(forKey: "osc-ip") ?? "0.0.0.0"
        let port = UserDefaults.standard.integer(forKey: "osc-port")
        let alert = UIAlertController(title: "OSC", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = ip
        }
        alert.addTextField { textField in
            textField.text = "\(port)"
        }
        alert.addAction(UIAlertAction(title: "Setup", style: .default, handler: { _ in
            let ip = alert.textFields![0].text ?? "0.0.0.0"
            let port = Int(alert.textFields![1].text ?? "0") ?? 0
            UserDefaults.standard.set(ip, forKey: "osc-ip")
            UserDefaults.standard.set(port, forKey: "osc-port")
            self.oscClientButton.setTitle("Client: \(ip):\(port)", for: .normal)
            LFOSCClient.main.setup(ip: ip, port: port)
        }))
        alert.addAction(UIAlertAction(title: "Ping", style: .default, handler: { _ in
            LFOSCClient.main.send(1, to: "ping")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if canAR {
            ar!.pause()
        }
    }
    
    // MARK: - Pixels
    
    func pixelFrameLoop() {
        fpsLabel.text = "\(PixelKit.main.fps) fps"
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
    
    @objc func rgbBgOnOff(btn: UIButton) {
        btn.tag = -btn.tag
        let r = rBgBtn.tag > 0 ? 1 : 0
        let g = gBgBtn.tag > 0 ? 1 : 0
        let b = bBgBtn.tag > 0 ? 1 : 0
        btn.alpha = btn.tag > 0 ? 1.0 : 1 / 3
        let c = LiveColor(r: LiveFloat(r) * 0.25, g: LiveFloat(g) * 0.25, b: LiveFloat(b) * 0.25)
        content.bg(color: c)
        ar?.bgSphere.firstMaterial?.diffuse.contents = c.uiColor
    }
    
    // MARK: Face Mask
    
    @objc func addFaceMask(longPess: UILongPressGestureRecognizer) {
        guard longPess.state == .began else { return }
        ViewAssistant.shared.alert("Luma Face", "AR\(canAR ? "" : " not") supported.", actions: [
            ViewAssistant.AlertAction(title: "Wireframe", style: .default, handeler: { _ in
                if self.canAR {
                    self.ar?.wireframeOn()
                } else {
                    self.sim?.wireframeOn()
                }
            }),
            ViewAssistant.AlertAction(title: "Next Image", style: .default, handeler: { _ in
                if self.canAR {
                    self.ar?.wireframeOff()
                } else {
                    self.sim?.wireframeOff()
                }
                self.content.loadNextImage()
            }),
//            ViewAssistant.AlertAction(title: "Next Video", style: .default, handeler: { _ in
//                self.content.loadNextVideo()
//            }),
            ViewAssistant.AlertAction(title: "Load Image", style: .default, handeler: { _ in
                FileAssistant.shared.media_picker_assistant.pickMedia(media_type: .photo, pickedImage: { image in
                    DispatchQueue.main.async {
//                        if canAR {
//                            self.ar!.addImage(image)
//                        } else {
//                            self.sim!.addImage(image)
//                        }
                        if self.canAR {
                            self.ar?.wireframeOff()
                        } else {
                            self.sim?.wireframeOff()
                        }
                        self.content.loadExternal(image: image)
                    }
                })
            }),
//            ViewAssistant.AlertAction(title: "Load PIX A Texture", style: .default, handeler: { _ in
//                if canAR {
//                    self.ar!.addPIXA()
//                }
//            }),
//            ViewAssistant.AlertAction(title: "Load PIX B Texture", style: .default, handeler: { _ in
//                if canAR {
//                    self.ar!.addPIXB()
//                }
//            }),
//            ViewAssistant.AlertAction(title: "Remove Texture", style: .destructive, handeler: { _ in
//                if canAR {
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
        if canAR {
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
