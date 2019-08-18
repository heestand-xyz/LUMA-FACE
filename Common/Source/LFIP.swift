//
//  LFIP.swift
//  Luma Face
//
//  Created by Hexagons on 2019-06-30.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import Foundation

class LFIP {
    
    static func getAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }
        
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            var addr = ptr.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses.append(address)
                    }
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return addresses
    }
    
    static func getAddress() -> String {
        let addresses = LFIP.getAddresses()
        var ip_address: String = "#.#.#.#"
        for address in addresses {
            let address_components = address.components(separatedBy: ".")
            if address_components[0] == "127" || address_components[0] == "172" || address_components[0] == "192" || /*address_components[0] == "169" ||*/ /*address_components[0] == "100" ||*/ address_components[0] == "192" || address_components[0] == "10" {
                ip_address = address
                break
            }
        }
        return ip_address
    }
    
}
