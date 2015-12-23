//
//  BLEActors.swift
//  Actors
//
//  Created by Dario Lencina on 9/29/15.
//  Copyright © 2015 dario. All rights reserved.
//

import Foundation
import UIKit
import Theater
import CoreBluetooth
import AudioToolbox

public class ScannerConnection : ViewCtrlActor<StatusController>, WithListeners {
    
    public var listeners : [ActorRef] = [ActorRef]()
    
    public struct States {
        let connected = "connected"
    }
    
    let states = States()
    
    var devices : BLECentral.PeripheralObservations = BLECentral.PeripheralObservations()
    var identifiers : [String] = [String]()
    var selectedIdentifier : Optional<String> = nil
    lazy var central : ActorRef = self.actorOf(BLECentral.self, name:"BLECentral")
    
    required public init(context : ActorSystem, ref : ActorRef) {
        super.init(context: context, ref: ref)
        self.central ! BLECentral.AddListener(sender: this)
    }
    
    public override func receiveWithCtrl(ctrl: StatusController) -> Receive {
        return {[unowned self](msg : Actor.Message) in
            switch(msg) {
                
            case let m as BLECentral.StateChanged:
                print("state \(m.state)")
                
            case let m as BLECentral.StartScanning:
                self.central ! BLECentral.StartScanning(services: m.services, sender: self.this)
                ^{
                ctrl.setBluetoothStatus("Scanning (make sure that bluetooth is on)")
                }
                self.addListener(m.sender)
                
            case is BLECentral.StopScanning:
                self.central ! BLECentral.StopScanning(sender: self.this)
                ^{
                ctrl.setBluetoothStatus("Not Scanning")
                }
                
            case let observation as BLECentral.DevicesObservationUpdate:
                self.devices = observation.devices
                self.identifiers = Array(self.devices.keys)
                self.broadcast(observation)
                //TODO: show this on the UI
                //TODO: send devices to backend
                
            default:
                self.receive(msg)
            }
        }
    }
}

