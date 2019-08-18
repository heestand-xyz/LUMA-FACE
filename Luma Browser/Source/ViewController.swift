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
    
    var oscButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let contentImages = FileLoader.getContentImages()
        
        lumaBrowseView = LumaBrowseView(images: contentImages)
        lumaBrowseView.delegate = self
        view.addSubview(lumaBrowseView)
        
        liveCamView = LiveCamView(frame: view.bounds)
        
        let ip = UserDefaults.standard.string(forKey: "osc-ip") ?? "0.0.0.0"
        let port = UserDefaults.standard.integer(forKey: "osc-port")
        LFOSCClient.main.setup(ip: ip, port: port)
        
        oscButton = UIButton(type: .system)
        oscButton.tintColor = .white
        oscButton.addTarget(self, action: #selector(oscSetup), for: .touchUpInside)
        oscButton.setTitle("\(ip):\(port)", for: .normal)
        view.addSubview(oscButton)
        
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
        
        oscButton.translatesAutoresizingMaskIntoConstraints = false
        oscButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        oscButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        
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
            self.oscButton.setTitle("\(ip):\(port)", for: .normal)
            LFOSCClient.main.setup(ip: ip, port: port)
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

