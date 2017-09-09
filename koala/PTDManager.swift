//
//  BLEManager.swift
//  koala
//
//  Created by Adrian on 7/21/16.
//  Copyright © 2016 Adrian Pearl. All rights reserved.
//

//import Bean_iOS_OSX_SDK
import UIKit

final class PTDManager: NSObject, PTDBeanManagerDelegate, PTDBeanDelegate {
    
    static let sharedInstance = PTDManager()
    
    private override init() {
        super.init()
    }
    
    private var status: workoutStatus = .Disconnected
    private var wktMode: Bool = false
    
    private let manager = PTDBeanManager()
    private var schedule = [UILocalNotification:PTDBean]()
    
    private let locatorService = CBUUID(string: "A495FF10-C5B1-4B44-B512-1370F02D74DE")
    
    private let koalaServices = [CBUUID(string: "A495FF20-C5B1-4B44-B512-1370F02D74DE"),
                                 CBUUID(string: "F000FFC0-0451-4000-B000-000000000000"),
                                 CBUUID(string: "A495FF10-C5B1-4B44-B512-1370F02D74DE")]
    
    private let koalaChars = [CBUUID(string: "A495FF21-C5B1-4B44-B512-1370F02D74DE"),
                              CBUUID(string: "A495FF22-C5B1-4B44-B512-1370F02D74DE"),
                              CBUUID(string: "A495FF23-C5B1-4B44-B512-1370F02D74DE"),
                              CBUUID(string: "A495FF24-C5B1-4B44-B512-1370F02D74DE"),
                              CBUUID(string: "A495FF25-C5B1-4B44-B512-1370F02D74DE")]
    
    func stateChange(workoutMode: Bool) -> Bool {
        var result: Bool = false
        if workoutMode {
            if manager.state == .PoweredOn {
                startScanning()
                wktMode = true
                result = true
            } else {
                print("[DEBUG] Error: Bluetooth not powered on")
            }
        } else {
            stopBLE()
            wktMode = false
            result = true
        }
        return result
    }
    
    func connect(notification: UILocalNotification) {
        if let koalaToConnect = schedule[notification] {
            var error: NSError?
            manager.connectToBean(koalaToConnect, error: &error)
            if let e = error {
                print(e)
            } else {
                print("[DEBUG] connecting to: \(koalaToConnect.name)")
                status = .Connecting
            }
        }
    }
    
    private enum workoutStatus {
        case Searching
        case Found
        case Connecting
        case Collecting
        case Disconnected
        case ConnectionFailed
        case ConnectionLost
    }
    
    private func startScanning() {
        var error: NSError?
        manager.startScanningForBeans_error(&error)
        if let e = error {
            print(e)
        } else {
            print("[DEBUG] started scanning")
            status = .Searching
            manager.delegate = self
        }
    }
    
    private func stopBLE() {
        var error1: NSError?
        var error2: NSError?
        manager.stopScanningForBeans_error(&error1)
        manager.disconnectFromAllBeans(&error2)
        if let e = error1 {
            print(e)
        } else if let e = error2 {
            print(e)
        } else {
            print("[DEBUG] BLE disabled")
            status = .Disconnected
        }
    }
    
    // MARK: - CBCentralManager Delegate
    
//    func centralManagerDidUpdateState(central: CBCentralManager) {
//        let state = manager.state
//        if state != .PoweredOn && wktMode {
//            print("[DEBUG] Error: in workout mode but BLE not powered on")
//        }
//    }
    
    func beanManager(beanManager: PTDBeanManager!, didDiscoverBean bean: PTDBean!, error: NSError!, strength RSSI: NSNumber!) {
        print("[DEBUG] discovered peripheral: \(bean.name)")
        var error1: NSError?
        manager.connectToBean(bean, error: &error1)
        if let e = error1 {
            print(e)
        } else {
            print("[DEBUG] connecting to: \(bean.name)")
            status = .Connecting
        }
    }
    
    func beanManager(beanManager: PTDBeanManager!, didConnectBean bean: PTDBean!, error: NSError!) {
        print("[DEBUG] connected to: \(bean.name)")
        bean.delegate = self
        status = .Collecting
    }
        
}