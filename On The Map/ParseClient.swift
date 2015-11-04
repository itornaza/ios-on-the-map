//
//  ParseClient.swift
//  On The Map
//
//  Created by Ioannis Tornazakis on 22/4/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import Foundation
import UIKit

class ParseClient: NSObject {
    
    // MARK: - POST
    
    class func postStudentData(studentLink: String, mapString: String, latitude: Double, longitude: Double,
        completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        // Get the App Delegate to further use the globals
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        
        // 2. Build the URL
        let urlString = ParseClient.Constants.BaseURLSecure + ParseClient.Methods.StudentLocation
        let url = NSURL(string: urlString)!
        
        // 3. Configure the request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue(ParseClient.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(appDelegate.key)\", \"firstName\": \"\(appDelegate.firstName)\", \"lastName\": \"\(appDelegate.lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(studentLink)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        // 4. Make the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if error != nil {
                completionHandler(
                    success: false,
                    errorString: ParseClient.Constants.FailedConnection
                )
                return
            }
            
            // 5. Parse the data
            Helpers.parseJSONWithCompletionHandler(data!) { result, error in
                
                if error != nil {
                    completionHandler(
                        success: false,
                        errorString: ParseClient.Constants.ParsingError
                    )
                    return
                }
                
                // 6. Use the data
                if let _ = result!.valueForKey(ParseClient.JSONResponseKeys.ObjectID) as? String {
                    completionHandler(success: true, errorString: nil)
                }
            }
        }
        
        // 7. Start the request
        task.resume()

    }
    
    // MARK: - GET
    
    class func getStudentData(completionHandler: (result: [StudentInfo]?, error: String?) -> Void) {
        
        // 1. Set the parameters
        let methodParameters = [ParseClient.ParameterKeys.Limit: ParseClient.ParameterValues.Limit]
        
        // 2. Build the URL
        let urlString = ParseClient.Constants.BaseURLSecure + ParseClient.Methods.StudentLocation +
            Helpers.escapedParameters(methodParameters)
        _ = NSURL(string: urlString)!
        
        // 3. Configure the request
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.addValue(ParseClient.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        // 4. Make the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(result: nil, error: ParseClient.Constants.FailedConnection)
                return
            }
            
            // 5. Parse the data
            Helpers.parseJSONWithCompletionHandler(data!) { result, error in
                
                if error != nil {
                    completionHandler(result: nil, error: error)
                    return
                }
                
                // 6. Use the data
                let studentsArray: [[String:AnyObject]] = (result?.valueForKey("results") as? [[String:AnyObject]])!
                let studentsInfo: [StudentInfo] = StudentInfo.studentInfoFromResults(studentsArray)
                completionHandler(result: studentsInfo, error: nil)
            }
        }
        
        // 7. Start the request
        task.resume()
    }

}
