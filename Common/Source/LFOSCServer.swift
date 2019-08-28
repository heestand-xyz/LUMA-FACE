//
//  OSC.swift
//  PixelKit
//
//  Created by Hexagons on 2019-06-02.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import OSCKit

public class LFOSCServer: NSObject, OSCServerDelegate {
    
    public static let main = LFOSCServer()
    
    public var port: Int = 8888 {
        didSet {
            server.stop()
            server.listen(port)
        }
    }
    
    let server: OSCServer
    
    public var log: Bool = false
    
    struct Listener {
        let address: String
        let callback: (Any) -> ()
    }
    var listeners: [Listener] = []

    override init() {
        
        server = OSCServer()
        
        super.init()
        
        server.delegate = self
        server.listen(port)
        
    }
    
    public func handle(_ message: OSCMessage!) {
        guard var address = message.address else { return }
        address = address.replacingOccurrences(of: "/", with: "")
        let value = message.arguments[0]
        for listener in listeners {
            if address == listener.address {
                listener.callback(value)
            }
        }
        if self.log { print("OSC:", address, value) }
    }
    
    public func listen(to address: String, callback: @escaping (Any) -> ()) {
        listeners.append(Listener(address: "/" + address, callback: callback))
    }
    
}
