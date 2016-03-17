//
//  WSViewController.swift
//  Actors
//
//  Created by Dario Lencina on 9/29/15.
//  Copyright © 2015 dario. All rights reserved.
//

import UIKit
import Theater
import CoreBluetooth

class WebSocketConnection : ViewCtrlActor<StatusController>  {
    
    struct States {
        let connecting = "Connecting"
        let connected = "Connected"
        let disconnected = "Disconnected"
    }
    
    let states = States()
    
    lazy var wsClient : ActorRef = self.actorOf(WebSocketClient.self, name:"WebSocketClient")
    
    var receivedMessages : [(String, NSDate)] = [(String, NSDate)]()
    
    override func receive(msg: Actor.Message) {
        switch(msg) {
            case let m as BLECentral.DevicesObservationUpdate:
                
                var payload : [[String : String]] = [[String : String]]()
                m.devices.forEach { (identifier, observations) in
                    let first : BLECentral.BLEPeripheralObservation = observations.first!
                    
                    if let services = (first.advertisementData[CBAdvertisementDataServiceUUIDsKey] as? NSArray),
                    let serviceUUID = services[0].UUIDString{
                    
                    
                    var dict = ["RSSI":first.RSSI.description, "identifier":identifier,
                        "timeIntervalSince1970" : first.timestamp.timeIntervalSince1970.description,
                        "serviceUUID" : serviceUUID]
                    
                    if let name = first.peripheral.name {
                        dict["name"] = name
                    }
                    
                        payload.append(dict)
                    }
                }
                
                
                do {
                    let jsonData = try NSJSONSerialization.dataWithJSONObject(payload, options: NSJSONWritingOptions.PrettyPrinted)
                    //TODO: support sending data
                    wsClient ! WebSocketClient.SendMessage(sender: self.this, message: String(data: jsonData, encoding: NSUTF8StringEncoding)!)
                }catch let error as NSError{
                    print(error.description)
                }
            
            default:
                print("not handled")
        }
    }
    
    
    // MARK: Actor states
    
    override func receiveWithCtrl(ctrl : StatusController) -> Receive {

        return {[unowned self] (msg : Actor.Message) in
            switch(msg) {
            case is WebSocketClient.Connect:
                self.become(self.states.disconnected, state: self.disconnected(ctrl))
                self.this ! msg
                
            default:
                ctrl.tableView.dataSource = nil
                ctrl.tableView.delegate = nil
                self.receive(msg)
            }
        }
    }
    
    func disconnected(ctrl : StatusController) -> Receive {
        return {[unowned self] (msg : Actor.Message) in
            switch(msg) {
            case let w as WebSocketClient.Connect:
                self.become(self.states.connecting, state: self.connecting(ctrl, url:w.url,  headers : w.headers))
                self.wsClient ! WebSocketClient.Connect(url: w.url, headers: w.headers, sender: self.this)
                ^{ ctrl.setWebSocketStatus("Connecting")}
                
            case let m as WebSocketClient.OnDisconnect:
                ^{ctrl.setWebSocketStatus("Disconnected")
                 ctrl.navigationItem.prompt = m.error?.localizedDescription}
                
            default:
                self.receive(msg)
            }
        }
    }
    
    func connecting(ctrl : StatusController, url : NSURL, headers : Dictionary<String,String>?) -> Receive {
        return {[unowned self] (msg : Actor.Message) in
            switch(msg) {
                
            case is WebSocketClient.OnConnect:
                ^{ctrl.setWebSocketStatus("Connected")
                  ctrl.navigationItem.prompt = nil
                }
                self.become(self.states.connected, state:self.connected(ctrl, url: url, headers: headers))
                
            case let m as WebSocketClient.OnDisconnect:
                self.unbecome()
                self.this ! m

                self.scheduleOnce(1,block: {
                    self.this ! WebSocketClient.Connect(url: url, headers: headers, sender: self.this)
                })
            
            default:
                self.receive(msg)
            }
        
        }
    }
    
    func connected(ctrl : StatusController, url : NSURL, headers : Dictionary<String,String>?) -> Receive {
        
        return {[unowned self](msg : Actor.Message) in
            switch(msg) {
                case let w as WebSocketClient.SendMessage:
                    /*self.receivedMessages.append(("You: \(w.message)", NSDate.init()))
                    let i = self.receivedMessages.count - 1
                    ^{
                      let lastRow = NSIndexPath.init(forRow: i, inSection: 0)
                      ctrl.tableView.insertRowsAtIndexPaths([lastRow], withRowAnimation: UITableViewRowAnimation.Automatic)
                      ctrl.tableView.scrollToRowAtIndexPath(lastRow, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)} */
                    self.wsClient ! WebSocketClient.SendMessage(sender: self.this, message: w.message)
                
                case let w as WebSocketClient.OnMessage:
                    self.receivedMessages.append(("Server: \(w.message)", NSDate.init()))
                    /*let i = self.receivedMessages.count - 1
                    ^{
                      let lastRow = NSIndexPath.init(forRow: i, inSection: 0)
                      ctrl.tableView.insertRowsAtIndexPaths([lastRow], withRowAnimation: UITableViewRowAnimation.Automatic)
                      ctrl.tableView.scrollToRowAtIndexPath(lastRow, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)}*/
                    
                case let m as WebSocketClient.OnDisconnect:
                    self.popToState(self.states.disconnected)
                    self.this ! m
                    self.scheduleOnce(1,block: {
                        self.this ! WebSocketClient.Connect(url: url, headers : headers, sender: self.this)
                    })
                    
                default:
                    self.receive(msg)
            }
        }
    }

    required init(context: ActorSystem, ref: ActorRef) {
        super.init(context: context, ref: ref)
    }

}
