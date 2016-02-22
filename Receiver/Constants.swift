//
//  Constants.swift
//  CheckIniOS
//
//  Created by Dario Lencina on 12/22/15.
//  Copyright © 2015 BlackFireApps. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct BLEData {
    let svc = CBUUID(string: "71DA3FD1-7E10-41C1-B16F-4430B506CDE7")
    let characteristic = CBUUID(string: "71DA3FD1-7E10-41C1-B16F-4430B506CDE2")
}

struct C {
    static let backendURL = "http://192.168.1.73:9001/receiverSocket"
//        static let backendURL = "http://darioalessandro.com:9005/receiverSocket"
    struct BLE {
        static let svc = CBUUID(string: "71DA3FD1-7E10-41C1-B16F-4430B506CDE7")
        static let characteristic = CBUUID(string: "71DA3FD1-7E10-41C1-B16F-4430B506CDE2")
    }
}
