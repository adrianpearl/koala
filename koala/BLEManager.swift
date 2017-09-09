//
//  BLEManager.swift
//
//  Created by Adrian on 7/21/16.
//  Copyright © 2016 Adrian Pearl. All rights reserved.
//

import CoreBluetooth
import UIKit

final class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    static let sharedInstance = BLEManager()
    
    private override init() {
        super.init()
    }
    
    private var status: workoutStatus = .Disconnected
    private var wktMode: Bool = false
    
    private let manager = CBCentralManager()
    private var schedule = [UILocalNotification:CBPeripheral]()
    
    private let locatorService = CBUUID(string: "A495FF10-C5B1-4B44-B512-1370F02D74DE")
    
    private let theService = CBUUID(string: "A495FF20-C5B1-4B44-B512-1370F02D74DE")
    
    private let theCharacteristics = [CBUUID(string: "A495FF21-C5B1-4B44-B512-1370F02D74DE"),
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
            manager.connectPeripheral(koalaToConnect, options: nil)
            print("[DEBUG] connecting to: \(koalaToConnect.name)")
            status = .Connecting
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
        manager.scanForPeripheralsWithServices([locatorService], options: nil)
        print("[DEBUG] started scanning")
        status = .Searching
        manager.delegate = self
    }
    
    private func stopBLE() {
        manager.stopScan()
    }
    
    // MARK: - CBCentralManager Delegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        let state = manager.state
        if state != .PoweredOn && wktMode {
            print("[DEBUG] Error: in workout mode but BLE not powered on")
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("[DEBUG] discovered peripheral: \(peripheral.name)")
        let notification = UILocalNotification()
        notification.category = CatID
        notification.fireDate = NSDate(timeIntervalSinceNow: 1)
        notification.alertBody = "Are you using \(peripheral.name!)?"
        schedule[notification] = peripheral
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
//        manager.connectPeripheral(peripheral, options: nil)
//        manager.stopScan()
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("[DEBUG] connected to: \(peripheral.name)")
        peripheral.delegate = self
        peripheral.discoverServices([theService])
        status = .Collecting
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("[DEBUG] DID DISCONNECT")
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("[DEBUG] DID FAIL TO CONNECT")
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        print("[DEBUG] will restore state? ok")
    }
    
    // MARK: - CBPeripheral Delegate
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let e = error {
            print(e)
        } else {
            print("[DEBUG] discovered \(peripheral.services?.count) services for: \(peripheral.name)")
            if let theServices = peripheral.services {
                for service in theServices {
                    print(service.UUID)
                    peripheral.discoverCharacteristics([theCharacteristics[0]], forService: service)
                    print("[DEBUG] discovering chars for service")
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let e = error {
            print(e)
        } else {
            print("[DEBUG] discovered \(service.characteristics?.count) characteristics for: \(service)")
            if let characteristic = service.characteristics?.first {
                if characteristic.UUID == theCharacteristics[0] {
                    print("[DEBUG] found koalaChar, subscribing...")
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let e = error {
            print(e)
        } else if characteristic.UUID == theCharacteristics[0] {
            manager.cancelPeripheralConnection(peripheral)
            print("[DEBUG] received updated value")
            print("[DEBUG] length: \(characteristic.value?.length)")
            if let count = characteristic.value?.length {
                var array = [Int8](count: count, repeatedValue: 0)
                characteristic.value?.getBytes(&array, length: count)
                for element in array {
                    print(String(element, radix: 2))
                }
                
                // Koala's name is a known workout followed by a double space and then a number.
                // We remove the double space and number to make the name match a dictionary entry in knownExercises.
                let tokens = peripheral.name!.componentsSeparatedByString("  ") // <-- double space
                
                let exercise = koalaExercise.classify(tokens[0], time: NSDate(), data: array)
                koalaUser.exercises.append(exercise)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("[DEBUG] DID MODIFY SERVICES")
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        print("[DEBUG] DID WRITE VALUE FOR DESCRIPTOR")
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        print("[DEBUG] DID UPDATE VALUE FOR DISCRIPTOR")
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverIncludedServicesForService service: CBService, error: NSError?) {
        print("[DEBUG] DID DISCOVER INCLUDED SERVICES")
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("[DEBUG] DID DISCOVER DESCRIPTORS FOR CHAR")
    }
    
}