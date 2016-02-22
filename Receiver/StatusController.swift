//
//  StatusController.swift
//  CheckIniOS
//
//  Created by Dario Lencina on 12/22/15.
//  Copyright © 2015 BlackFireApps. All rights reserved.
//

import UIKit
import Theater

public class StatusController : UITableViewController {
    
    var rows : [[UITableViewCell]] = [[UITableViewCell]]()
    public var bluetoothRow : UITableViewCell? = nil
    public var webSocketRow : UITableViewCell? = nil
    public let system : ActorSystem = ActorSystem(name:"ActorLand")
    lazy var WSConnection : ActorRef =
        self.system.actorOf(WebSocketConnection.self, name : "WebSocketConnection")
    lazy var BLEConnection : ActorRef =
        self.system.actorOf(ScannerConnection.self, name : "ScannerConnection")
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        WSConnection ! SetViewCtrl(ctrl: self)
        BLEConnection ! SetViewCtrl(ctrl: self)
        let receiverId = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
        WSConnection ! WebSocketClient.Connect(url: NSURL(string: C.backendURL)!, headers: ["receiverId":receiverId, "username":"dario"], sender: nil)
        BLEConnection ! BLECentral.StartScanning(services: [C.BLE.svc], sender: WSConnection)

        bluetoothRow = self.tableView.dequeueReusableCellWithIdentifier("Bluetooth")
        webSocketRow = self.tableView.dequeueReusableCellWithIdentifier("WebSocket")
        rows = [[
            bluetoothRow!,
            webSocketRow!
        ]]
        setBluetoothStatus("Disconnected")
        setWebSocketStatus("Not Scanning")
    }
    
    public func setBluetoothStatus(status : String) {
        if let bluetoothRow = self.bluetoothRow {
            bluetoothRow.textLabel?.text = "Bluetooth Status"
            bluetoothRow.detailTextLabel?.text = status
        }
    }
    
    public func setWebSocketStatus(status : String) {
        if let webSocketRow = self.webSocketRow {
            webSocketRow.textLabel?.text = "Server Connection"
            webSocketRow.detailTextLabel?.text = status
        }
    }
    
    public func setDevices(devices : [BLECentral.BLEPeripheralObservation]) {
        
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = rows[indexPath.section][indexPath.row]
        return cell
    }
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return rows.count
    }
    
    override public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0:
            return "INTERFACES STATUS"
        case 1:
            return "VISIBLE BEACONS"
        default:
            return ""
        }
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].count
    }
}