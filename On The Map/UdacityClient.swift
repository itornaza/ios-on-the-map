//
//  UdacityClient.swift
//  On The Map
//
//  Created by Ioannis Tornazakis on 21/4/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit

class UdacityClient: NSObject {
    
    // MARK: - POST
    
    class func authenticate(_ email: String, password: String,
        completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {

        // Get the App Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        
        // 1. Set the parameters
        let methodParameters = [
            UdacityClient.ParameterKeys.Email: email,
            UdacityClient.ParameterKeys.Password: password
        ]
        
        // 2. Build the URL
        let urlString = UdacityClient.Constants.BaseURLSecure + UdacityClient.Methods.Session +
            Helpers.escapedParameters(methodParameters as [String : AnyObject])
        let url = URL(string: urlString)!
        
        // 3. Configure the request
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        
        // 4. Make the request
        let session = URLSession.shared
        let task =  session.dataTask(with: request as URLRequest, completionHandler: { data, response, downloadError in
            
            if let _ = downloadError {
                
                // Authentication failed due to connection issues
                completionHandler(
                    UdacityClient.AuthenticationStatus.Failure,
                    UdacityClient.AuthenticationStatus.FailedConnection
                )
                return
                
            } else {

                // Get rid of the first 5 characters that Udacity places for security
                
                // TODO (Check conversion): let newData = data!.subdata(in: NSMakeRange(5, data!.count - 5))
                let newData = data!.subdata(in: 5..<(data!.count - 5))
                
                // 5. Parse the data
                Helpers.parseJSONWithCompletionHandler(newData) { result, error in
                
                    // 6. Use the data!
                    
                    // Authentication failed due to parsing issues
                    if error != nil {
                        completionHandler(
                            UdacityClient.AuthenticationStatus.Failure,
                            UdacityClient.AuthenticationStatus.ParseError
                        )
                        return
                    }
                    
                    // Authentication success
                    if let account = result?.value(forKey: UdacityClient.JSONResponseKeys.Account) as? NSDictionary {
                        if let key = account.value(forKey: UdacityClient.JSONResponseKeys.Key) as? String {
                            
                            // Get the key and assign it to the app Delegate
                            appDelegate.key = key
                            
                            self.getUserData(){ success, errorString in
                                if errorString != nil {
                                    completionHandler(
                                        UdacityClient.AuthenticationStatus.Failure,
                                        errorString
                                    )
                                    return
                                } else {
                                    completionHandler(
                                        UdacityClient.AuthenticationStatus.Success,
                                        nil
                                    )
                                }
                            }
                        }
                        
                    // Authentication failed due to invalid credentials or non existing account
                    } else if let errorStatus = result?.value(forKey: UdacityClient.JSONResponseKeys.Status) as? Int {
                        if errorStatus == UdacityClient.JSONResponseKeys.ErrorStatus {
                            completionHandler(
                                UdacityClient.AuthenticationStatus.Failure,
                                UdacityClient.AuthenticationStatus.InvalidCredentials)
                            return
                        }
                    }
                }
            }
        }) 
        
        // 7. Start the request
        task.resume()
    }

    // MARK: - Get
    
    class func getUserData(_ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        // Get the App Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        
        // 1. Set the parameters
        
        // 2. Build the URL
        let urlString = UdacityClient.Constants.BaseURLSecure + UdacityClient.Methods.Users
            + "/\(appDelegate.key)"
        let url = URL(string: urlString)!
        
        // 3. Configure the request
        let request = NSMutableURLRequest(url: url)
        
        // 4. Make the request
        let session = URLSession.shared
        let task =  session.dataTask(with: request as URLRequest, completionHandler: { data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(false, UdacityClient.AuthenticationStatus.FailedConnection)
                return
            }
            
            // Get rid of the first 5 characters that Udacity places for security
            // TODO (Check conversion): let newData = data!.subdata(in: NSMakeRange(5, data!.count - 5))
            // let newData = data!.subdata(in: NSMakeRange(5, data!.count - 5))
            let newData = data!.subdata(in: 5..<(data!.count - 5))
            
            // 5. Parse the data
            Helpers.parseJSONWithCompletionHandler(newData) { result, error in

                // 6. Use the data
                if error != nil {
                    completionHandler(false, error)
                    return
                }
                
                // Get the first and last name of the student
                if let user = result?.value(forKey: UdacityClient.JSONResponseKeys.User) as? NSDictionary {
                    if let firstName = user.value(forKey: UdacityClient.JSONResponseKeys.FirstName) as? String {
                        if let lastName = user.value(forKey: UdacityClient.JSONResponseKeys.LastName) as? String {
                            appDelegate.lastName = lastName
                            appDelegate.firstName = firstName
                            completionHandler(true, nil)
                        }
                    }
                } else {
                    completionHandler(
                        false, UdacityClient.AuthenticationStatus.StudentDataFailed
                    )
                    return
                }
            }
        }) 
        
        // 7. Start the request
        task.resume()
    }
    
}

