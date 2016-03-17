//
//  BeaconSettings.swift
//  CheckIniOS
//
//  Created by Dario Lencina on 3/16/16.
//  Copyright © 2016 BlackFireApps. All rights reserved.
//

import UIKit
import CoreBluetooth

class BeaconSettings: NSObject {
    
    private let UUIDKey = "UUID"
    
    func UUID() -> CBUUID {
        if let uuid = NSUserDefaults.standardUserDefaults().stringForKey(UUIDKey) {
            return CBUUID(string: uuid)
        } else {
            return C.BLE.svc
        }
    }
    
    func setUUID(uuid : CBUUID) -> Void {
        NSUserDefaults.standardUserDefaults().setObject(uuid.UUIDString, forKey: UUIDKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

}
