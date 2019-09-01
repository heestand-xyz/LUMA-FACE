//
//  Hue.swift
//  Hueman
//
//  Created by Hexagons on 2019-03-02.
//  Copyright © 2019 Hexagons. All rights reserved.
//

import HomeKit
import PixelKit

protocol HueDelegate {
    func lightsWillChange(to color: LiveColor)
    func lightsDidChange(to color: LiveColor)
}

class Hue: NSObject, /*PHSBridgeConnectionObserver, PHSBridgeStateUpdateObserver*/ HMHomeManagerDelegate {
    
//    static let shared = Hue()
    
    var delegate: HueDelegate?
    
    let homeManager = HMHomeManager()
    
    var home: HMHome?
    
    var isWritingLight = false
    
    let whiteList = ["Control Center", "Central Station", "Windows XP"] //"Capsule"
    var allLights: [HMService]? {
        return home?.servicesWithTypes([HMServiceTypeLightbulb])
    }
    var whiteLights: [HMService]? {
        guard allLights != nil else { return nil }
        var lights: [HMService] = []
        for light in allLights! {
            guard whiteList.contains(light.name) else { continue }
            lights.append(light)
        }
        return lights
    }
    var lightCount: Int {
        return whiteList.count
    }

    override init() {
        print("Hue Init")
        super.init()
        homeManager.delegate = self
//        homeManager.addHome(withName: "The Bachelor Pad") { home, error in
//            guard error == nil else {
//                print("Home Error:", error!.localizedDescription)
//                return
//            }
//            self.home = home
//            print("Home Found:", home?.name ?? "-")
//        }
    }
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        home = homeManager.homes.first
        print("Auto Home Found:", home?.name ?? "-")
        light(color: .white, done: {
            self.light(color: .black)
        })
    }
    
    func light(color: LiveColor, index: Int? = nil, done: (() -> ())? = nil) {
        
        print("light...")
        
        guard let home = home else { return }
        
//        guard !isWritingLight else { return }
        isWritingLight = true
        
        print("_________")
        print("set light")
        print("color:", color)
        
        delegate?.lightsWillChange(to: color)
        
        var start = Date()

        guard let lights = whiteLights else { return }
//        print("lights:", lights)
        
        var count = index != nil ? 1 : whiteList.count //lights.count
        var hueCount = count
        var satCount = count
        var valCount = count
        func checkDone() {
            if hueCount == 0 && satCount == 0 && valCount == 0 {
                print("duration:", -start.timeIntervalSinceNow)
                print("light set")
                print(".........")
                isWritingLight = false
                delegate?.lightsDidChange(to: color)
                done?()
            }
        }
        
        for (i, light) in lights.enumerated() {
            print("Light:", light.name)
            if index != nil {
                guard i == index! else { continue }
            }
            guard whiteList.contains(light.name) else { continue }
            for characteristic in light.characteristics {
                if characteristic.characteristicType == HMCharacteristicTypeHue {
                    let hue = color.hue.cg
                    characteristic.writeValue(hue * 360) { error in
                        print("hue:", hue, "for:", light.name, error?.localizedDescription ?? "")
                        hueCount -= 1
                        checkDone()
                    }
                } else if characteristic.characteristicType == HMCharacteristicTypeSaturation {
                    let sat = color.sat.cg
                    characteristic.writeValue(sat * 100) { error in
                        print("sat:", sat, "for:", light.name, error?.localizedDescription ?? "")
                        satCount -= 1
                        checkDone()
                    }
                } else if characteristic.characteristicType == HMCharacteristicTypeBrightness {
                    let val = color.val.cg
                    characteristic.writeValue(val * 100) { error in
                        print("val:", val, "for:", light.name, error?.localizedDescription ?? "")
                        valCount -= 1
                        checkDone()
                    }
                }
            }
        }
        
    }

//    accessory: <HMAccessory, Name = Hue color lamp, Identifier = D398FAFD-76B4-5F34-A87B-9F6A3B647AF8, Reachable = YES>
//    accessory: <HMAccessory, Name = Hue color lamp, Identifier = 07B1F553-72FC-535C-956C-7AB5885B9D09, Reachable = YES>
//    accessory: <HMAccessory, Name = Hue color lamp, Identifier = 555DFACF-6ED8-5FCB-B1D4-36D58A75FEE9, Reachable = YES>
//    accessory: <HMAccessory, Name = Hue color lamp, Identifier = B97AECA8-77D0-5050-A0F2-0B39650BF640, Reachable = YES>
//    accessory: <HMAccessory, Name = Hue color lamp, Identifier = 9864CF2B-ECF1-5330-A182-BB4B61D868F4, Reachable = YES>
   
//    lazy var bridgeDiscovery: PHSBridgeDiscovery = PHSBridgeDiscovery()
//
//    func discover() {
//        print("search...")
//        bridgeDiscovery.search(.discoveryOptionUPNP) { results, returnCode in
//            guard let bridgeInfo = results?.first?.value else {
//                print("No bridge found.")
//                return
//            }
//            print("discovered")
//            let bridge = self.buildBridge(ipAddress: bridgeInfo.ipAddress, uniqueId: bridgeInfo.uniqueId)
//            self.connect(to: bridge)
//        }
//
//    }
//
//    func connect(to bridge: PHSBridge) {
//        let connectCode = bridge.connect()
//        print("_____connect:", connectCode)
//    }
//
//    func buildBridge(ipAddress: String, uniqueId: String) -> PHSBridge {
//        return PHSBridge.init(block: { (builder) in
//            builder?.connectionTypes = .local
//            builder?.ipAddress = ipAddress
//            builder?.bridgeID  = uniqueId
//            builder?.bridgeConnectionObserver = self
//            builder?.add(self)
//        }, withAppName: "Hueman", withDeviceName: "MyDevice")
//    }
//
//    func bridgeConnection(_ bridgeConnection: PHSBridgeConnection!, handle connectionEvent: PHSBridgeConnectionEvent) {
//        print("__________", "bridgeConnection", bridgeConnection)
//    }
//
//    func bridgeConnection(_ bridgeConnection: PHSBridgeConnection!, handleErrors connectionErrors: [PHSError]!) {
//        print("__________", "bridgeConnection", "error")
//    }
//
//    func bridge(_ bridge: PHSBridge!, handle updateEvent: PHSBridgeStateUpdatedEvent) {
//        print("__________", "updateEvent", updateEvent)
//    }
    
}
