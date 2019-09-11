//
//  ViewController.swift
//  Luma Browser
//
//  Created by Hexagons on 2019-05-31.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LumaBrowseViewDelegate, TransformDelegate {
    
    var lumaBrowseView: LumaBrowseView!
//    var liveCamView: LiveCamView!
    var transformView: TransformView!
    
//    var oscServerButton: UIButton!
//    var oscClientButton: UIButton!
    
    var captureButton: UIButton!
    
    var captureState: CaptureState = .inactive {
        didSet {
            styleCapture()
        }
    }
    
    var lumaGateButton: UIButton!
    
    var lumaGate: Bool = false {
        didSet {
            styleLumaGate()
        }
    }
    
    var peer: Peer!
    var peerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let contentImages = FileLoader.getContentImages()
        
        lumaBrowseView = LumaBrowseView(images: contentImages)
        lumaBrowseView.delegate = self
        view.addSubview(lumaBrowseView)
        
        transformView = TransformView()
        transformView.delegate = self
        transformView.isHidden = true
        view.addSubview(transformView)
        
//        liveCamView = LiveCamView(frame: view.bounds)
        
        
//        LFOSCServer.main.port = 7777
//
//        let local_ip = LFIP.getAddress()
//        let local_port = LFOSCServer.main.port
//
//        oscServerButton = UIButton(type: .system)
//        oscServerButton.isEnabled = false
//        oscServerButton.tintColor = .white
//        oscServerButton.setTitle("Server: \(local_ip):\(local_port)", for: .normal)
//        view.addSubview(oscServerButton)
//
//        LFOSCServer.main.listen(to: "ping") { _ in
//            print("PING")
//            let alert = UIAlertController(title: "OSC Ping", message: nil, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//
//
//        let remote_ip = UserDefaults.standard.string(forKey: "osc-ip") ?? "0.0.0.0"
//        let remote_port = UserDefaults.standard.integer(forKey: "osc-port")
//        LFOSCClient.main.setup(ip: remote_ip, port: remote_port)
//
//        oscClientButton = UIButton(type: .system)
//        oscClientButton.tintColor = .white
//        oscClientButton.addTarget(self, action: #selector(oscSetup), for: .touchUpInside)
//        oscClientButton.setTitle("Client: \(remote_ip):\(remote_port)", for: .normal)
//        view.addSubview(oscClientButton)

        let tap = UITapGestureRecognizer(target: self, action: #selector(transformToggle))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
        peer = Peer(gotMsg: { message in
            print("peer msg:", message)
            if message == "ping" {
                let alert = UIAlertController(title: "Ping", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if message.starts(with: "capture") {
                guard let captureState = CaptureState(rawValue: message.replacingOccurrences(of: "capture:", with: "")) else { return }
                self.captureState = captureState
            } else if message.starts(with: "luma-gate") {
                let lumaGate = Int(message.replacingOccurrences(of: "luma-gate:", with: "")) == 1
                self.lumaGate = lumaGate
            }
        }, gotImg: { image in
            print("peer img")
        }, peer: { state, info in
            print("peer state:", state, "- info:", info)
            switch state {
            case .dissconnected:
                self.peerButton.tintColor = .darkGray
            case .connecting:
                self.peerButton.tintColor = .gray
            case .connected:
                self.peerButton.tintColor = .white
            }
        }, disconnect: {
            print("peer disconnect")
            self.peerButton.tintColor = .darkGray
            let alert = UIAlertController(title: "Peer Disconnect", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
        
        peerButton = UIButton(type: .system)
        peerButton.tintColor = .darkGray
        peerButton.addTarget(self, action: #selector(peerAction), for: .touchUpInside)
        peerButton.setTitle("IO", for: .normal)
        peerButton.titleLabel!.font = .systemFont(ofSize: 25, weight: .black)
        view.addSubview(peerButton)
        
        
        captureButton = UIButton()
        captureButton.addTarget(self, action: #selector(captureAction), for: .touchUpInside)
        captureButton.addTarget(self, action: #selector(captureDown), for: .touchDown)
        captureButton.addTarget(self, action: #selector(captureUp), for: .touchUpInside)
        captureButton.addTarget(self, action: #selector(captureUp), for: .touchUpOutside)
        captureButton.addTarget(self, action: #selector(captureUp), for: .touchCancel)
        view.addSubview(captureButton)
        
        styleCapture()
        
        
        lumaGateButton = UIButton()
        lumaGateButton.addTarget(self, action: #selector(lumaGateAction), for: .touchUpInside)
        lumaGateButton.addTarget(self, action: #selector(lumaGateDown), for: .touchDown)
        lumaGateButton.addTarget(self, action: #selector(lumaGateUp), for: .touchUpInside)
        lumaGateButton.addTarget(self, action: #selector(lumaGateUp), for: .touchUpOutside)
        lumaGateButton.addTarget(self, action: #selector(lumaGateUp), for: .touchCancel)
        view.addSubview(lumaGateButton)
                
        styleLumaGate()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        transformView.translatesAutoresizingMaskIntoConstraints = false
        transformView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        transformView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        transformView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        transformView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        lumaBrowseView.translatesAutoresizingMaskIntoConstraints = false
        lumaBrowseView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        lumaBrowseView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        lumaBrowseView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        lumaBrowseView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        
//        oscServerButton.translatesAutoresizingMaskIntoConstraints = false
//        oscServerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        oscServerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
//
//        oscClientButton.translatesAutoresizingMaskIntoConstraints = false
//        oscClientButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        oscClientButton.bottomAnchor.constraint(equalTo: oscServerButton.topAnchor, constant: -10).isActive = true
        
        peerButton.translatesAutoresizingMaskIntoConstraints = false
        peerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        peerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        captureButton.layer.cornerRadius = 50
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        captureButton.bottomAnchor.constraint(equalTo: peerButton.topAnchor, constant: -10).isActive = true
        captureButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        captureButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        
        lumaGateButton.layer.cornerRadius = 25
        lumaGateButton.translatesAutoresizingMaskIntoConstraints = false
        lumaGateButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        lumaGateButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        lumaGateButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        lumaGateButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
//    @objc func oscSetup() {
//        let ip = UserDefaults.standard.string(forKey: "osc-ip") ?? "0.0.0.0"
//        let port = UserDefaults.standard.integer(forKey: "osc-port")
//        let alert = UIAlertController(title: "OSC", message: nil, preferredStyle: .alert)
//        alert.addTextField { textField in
//            textField.text = ip
//        }
//        alert.addTextField { textField in
//            textField.text = "\(port)"
//        }
//        alert.addAction(UIAlertAction(title: "Setup", style: .default, handler: { _ in
//            let ip = alert.textFields![0].text ?? "0.0.0.0"
//            let port = Int(alert.textFields![1].text ?? "0") ?? 0
//            UserDefaults.standard.set(ip, forKey: "osc-ip")
//            UserDefaults.standard.set(port, forKey: "osc-port")
//            self.oscClientButton.setTitle("Client: \(ip):\(port)", for: .normal)
//            LFOSCClient.main.setup(ip: ip, port: port)
//        }))
//        alert.addAction(UIAlertAction(title: "Ping", style: .default, handler: { _ in
//            LFOSCClient.main.send(1, to: "ping")
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
    
    @objc func peerAction() {
        let alert = UIAlertController(title: "IO", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Connect", style: .default, handler: { _ in
            self.peer.joinSession()
        }))
        alert.addAction(UIAlertAction(title: "Ping", style: .default, handler: { _ in
            self.peer.sendMsg("ping")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func browsed(index: Int) {
        peer.sendMsg("index:\(index)")
//        LFOSCClient.main.send(index, to: "image-index")
    }
    
    @objc func transformToggle() {
        transformView.isHidden = !transformView.isHidden
    }
    
//    @objc func liveCamToggle() {
//        if liveCamView.superview != nil {
//            liveCamView.removeFromSuperview()
//        } else {
//            let alert = UIAlertController(title: "Live Cam", message: nil, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { _ in
//                view.addSubview(liveCamView)
//            }))
//            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
    
    func styleCapture() {
        captureButton.backgroundColor = captureState == .capture ? .red : captureState == .calibrate ? .blue : captureState == .live ? .white : .black
        captureButton.layer.borderWidth = captureState == .inactive ? 5 : 0
        captureButton.layer.borderColor = UIColor.white.cgColor
        lumaBrowseView.isUserInteractionEnabled = captureState != .calibrate
        lumaBrowseView.alpha = captureState != .calibrate ? 1.0 : 0.5
    }

    @objc func captureAction() {
        if captureState == .inactive {
            captureState = .calibrate
        } else if captureState == .calibrate {
            captureState = .capture
        } else if captureState == .capture {
            captureState = .live
        } else if captureState == .live {
            captureState = .inactive
        }
        peer.sendMsg("capture:\(captureState.rawValue)")
    }

    @objc func captureDown() {
        captureButton.alpha = 0.5
    }

    @objc func captureUp() {
        captureButton.alpha = 1.0
    }
    
    func styleLumaGate() {
        lumaGateButton.backgroundColor = lumaGate ? .green : .darkGray
    }

    @objc func lumaGateAction() {
        lumaGate.toggle()
        peer.sendMsg("luma-gate:\(lumaGate ? 1 : 0)")
    }

    @objc func lumaGateDown() {
        lumaGateButton.alpha = 0.5
    }

    @objc func lumaGateUp() {
        lumaGateButton.alpha = 1.0
    }
    
    
    // MARK - TransformDelegate
    
    func transform(position: CGPoint, zoom: CGFloat) {
        peer.sendMsg("transform:\(position.x),\(position.y),\(zoom)")
    }
    
}

