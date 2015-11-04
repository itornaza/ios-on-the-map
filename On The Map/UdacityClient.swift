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
    
    class func authenticate(email: String, password: String,
        completionHandler: (success: Bool, errorString: String?) -> Void) {

        // Get the App Delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        
        // 1. Set the parameters
        let methodParameters = [
            UdacityClient.ParameterKeys.Email: email,
            UdacityClient.ParameterKeys.Password: password
        ]
        
        // 2. Build the URL
        let urlString = UdacityClient.Constants.BaseURLSecure + UdacityClient.Methods.Session +
            Helpers.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        // 3. Configure the request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        // 4. Make the request
        let session = NSURLSession.sharedSession()
        let task =  session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let _ = downloadError {
                
                // Authentication failed due to connection issues
                completionHandler(
                    success: UdacityClient.AuthenticationStatus.Failure,
                    errorString: UdacityClient.AuthenticationStatus.FailedConnection
                )
                return
                
            } else {

                // Get rid of the first 5 characters that Udacity places for security
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                
                // 5. Parse the data
                Helpers.parseJSONWithCompletionHandler(newData) { result, error in
                
                    // 6. Use the data!
                    
                    // Authentication failed due to parsing issues
                    if error != nil {
                        completionHandler(
                            success: UdacityClient.AuthenticationStatus.Failure,
                            errorString: UdacityClient.AuthenticationStatus.ParseError
                        )
                        return
                    }
                    
                    // Authentication success
                    if let account = result.valueForKey(UdacityClient.JSONResponseKeys.Account) as? NSDictionary {
                        if let key = account.valueForKey(UdacityClient.JSONResponseKeys.Key) as? String {
                            
                            // Get the key and assign it to the app Delegate
                            appDelegate.key = key
                            
                            self.getUserData(){ success, errorString in
                                if errorString != nil {
                                    completionHandler(
                                        success: UdacityClient.AuthenticationStatus.Failure,
                                        errorString: errorString
                                    )
                                    return
                                } else {
                                    completionHandler(
                                        success: UdacityClient.AuthenticationStatus.Success,
                                        errorString: nil
                                    )
                                }
                            }
                        }
                        
                    // Authentication failed due to invalid credentials or non existing account
                    } else if let errorStatus = result.valueForKey(UdacityClient.JSONResponseKeys.Status) as? Int {
                        if errorStatus == UdacityClient.JSONResponseKeys.ErrorStatus {
                            completionHandler(
                                success: UdacityClient.AuthenticationStatus.Failure,
                                errorString: UdacityClient.AuthenticationStatus.InvalidCredentials)
                            return
                        }
                    }
                }
            }
        }
        
        // 7. Start the request
        task.resume()
    }

    // MARK: - Get
    
    class func getUserData(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        // Get the App Delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        
        // 1. Set the parameters
        
        // 2. Build the URL
        let urlString = UdacityClient.Constants.BaseURLSecure + UdacityClient.Methods.Users
            + "/\(appDelegate.key)"
        let url = NSURL(string: urlString)!
        
        // 3. Configure the request
        let request = NSMutableURLRequest(URL: url)
        
        // 4. Make the request
        let session = NSURLSession.sharedSession()
        let task =  session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(
                    success: false,
                    errorString: UdacityClient.AuthenticationStatus.FailedConnection
                )
                return
            }
            
            // Get rid of the first 5 characters that Udacity places for security
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            
            // 5. Parse the data
            Helpers.parseJSONWithCompletionHandler(newData) { result, error in

                // 6. Use the data
                if error != nil {
                    completionHandler(success: false, errorString: error)
                    return
                }
                
                // Get the first and last name of the student
                if let user = result.valueForKey(UdacityClient.JSONResponseKeys.User) as? NSDictionary {
                    if let firstName = user.valueForKey(UdacityClient.JSONResponseKeys.FirstName) as? String {
                        if let lastName = user.valueForKey(UdacityClient.JSONResponseKeys.LastName) as? String {
                            appDelegate.lastName = lastName
                            appDelegate.firstName = firstName
                            completionHandler(success: true, errorString: nil)
                        }
                    }
                } else {
                    completionHandler(
                        success: false,
                        errorString: UdacityClient.AuthenticationStatus.StudentDataFailed
                    )
                    return
                }
            }
        }
        
        // 7. Start the request
        task.resume()
    }
    
}

