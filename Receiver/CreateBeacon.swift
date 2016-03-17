//
//  CreateBeacon.swift
//  CheckIniOS
//
//  Created by Dario Lencina on 3/16/16.
//  Copyright © 2016 BlackFireApps. All rights reserved.
//

import UIKit
import CoreBluetooth
import Theater

public class CreateBeacon: NSObject {
    
    enum SvcError : ErrorType {
        case UnableToParse
    }
    
    public typealias Result = (NSDictionary?, NSError?) -> ()
    
    func createBeacon(peripheral : BLECentral.BLEPeripheralObservation, name : String, result : Result) {
        do {
        let request = NSMutableURLRequest(URL: NSURL(string: C.backendURL + "/beacon")!)
        request.HTTPMethod = "POST"
        let dict = ["name" : name]
        let jsonData = try NSJSONSerialization.dataWithJSONObject(dict, options: .PrettyPrinted)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")        
        request.setValue(OAuthLoginDataCache().loginData()!.cookie, forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonData
        request.timeoutInterval = 5
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            if let dataResp = data {
                do {
                let json = try NSJSONSerialization.JSONObjectWithData(dataResp, options: .AllowFragments)
                if let jsonDict = json as? NSDictionary {
                        result(jsonDict,error)
                } else {
                    throw SvcError.UnableToParse
                }
                } catch {
                    result(nil,NSError(domain: "unable to parse", code: 0, userInfo: nil))
                }
            } else {
                result(nil,error)
            }
        }
            
        task.resume()
            
        }catch {
            result(nil,NSError(domain: "Unable to parse json.", code: 000, userInfo: nil))
        }
    }

}
