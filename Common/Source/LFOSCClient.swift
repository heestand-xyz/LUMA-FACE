//
//  OSCClient.swift
//  
//
//  Created by Hexagons on 2019-06-30.
//

import OSCKit

public class LFOSCClient: NSObject {
    
    public static let main = LFOSCClient()
    
    let client: OSCClient
    
    var ip: String!
    var port: Int!
    
    override init() {
        
        client = OSCClient()
        
        super.init()
        
    }
    
    func setup(ip: String, port: Int) {
        self.ip = ip
        self.port = port
    }
    
    func send(_ value: Any, to address: String) {
        let message = OSCMessage(address: "/" + address, arguments: [value])
        let ip_address = "udp://\(ip!):\(port!)"
        client.send(message, to: ip_address)
    }
    
}
