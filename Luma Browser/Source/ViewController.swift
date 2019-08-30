//
//  ViewController.swift
//  Luma Browser
//
//  Created by Hexagons on 2019-05-31.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LumaBrowseViewDelegate {
    
    var lumaBrowseView: LumaBrowseView!
    var liveCamView: LiveCamView!
    
    var oscServerButton: UIButton!
    var oscClientButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let contentImages = FileLoader.getContentImages()
        
        lumaBrowseView = LumaBrowseView(images: contentImages)
        lumaBrowseView.delegate = self
        view.addSubview(lumaBrowseView)
        
        liveCamView = LiveCamView(frame: view.bounds)
        
        
        LFOSCServer.main.port = 7777
        
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
        
        
        let remote_ip = UserDefaults.standard.string(forKey: "osc-ip") ?? "0.0.0.0"
        let remote_port = UserDefaults.standard.integer(forKey: "osc-port")
        LFOSCClient.main.setup(ip: remote_ip, port: remote_port)
        
        oscClientButton = UIButton(type: .system)
        oscClientButton.tintColor = .white
        oscClientButton.addTarget(self, action: #selector(oscSetup), for: .touchUpInside)
        oscClientButton.setTitle("Client: \(remote_ip):\(remote_port)", for: .normal)
        view.addSubview(oscClientButton)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(liveCamToggle))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        lumaBrowseView.translatesAutoresizingMaskIntoConstraints = false
        lumaBrowseView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        lumaBrowseView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        lumaBrowseView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        lumaBrowseView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        
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
    
    func browsed(index: Int) {
        LFOSCClient.main.send(index, to: "image-index")
    }
    
    @objc func liveCamToggle() {
        if liveCamView.superview != nil {
            liveCamView.removeFromSuperview()
        } else {
            view.addSubview(liveCamView)
        }
    }

}

