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
    
    class func postStudentData(_ studentLink: String, mapString: String, latitude: Double, longitude: Double,
        completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        // Get the App Delegate to further use the globals
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        
        // 2. Build the URL
        let urlString = ParseClient.Constants.BaseURLSecure + ParseClient.Methods.StudentLocation
        let url = URL(string: urlString)!
        
        // 3. Configure the request
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(ParseClient.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(appDelegate.key)\", \"firstName\": \"\(appDelegate.firstName)\", \"lastName\": \"\(appDelegate.lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(studentLink)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
        
        // 4. Make the request
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            if error != nil {
                completionHandler(false, ParseClient.Constants.FailedConnection)
                return
            }
            
            // 5. Parse the data
            Helpers.parseJSONWithCompletionHandler(data!) { result, error in
                
                if error != nil {
                    completionHandler(false, ParseClient.Constants.ParsingError)
                    return
                }
                
                // 6. Use the data
                if let _ = result!.value(forKey: ParseClient.JSONResponseKeys.ObjectID) as? String {
                    completionHandler(true, nil)
                }
            }
        }) 
        
        // 7. Start the request
        task.resume()

    }
    
    // MARK: - GET
    
    class func getStudentData(_ completionHandler: @escaping (_ result: [StudentInfo]?, _ error: String?) -> Void) {
        
        // 1. Set the parameters
        let methodParameters = [ParseClient.ParameterKeys.Limit: ParseClient.ParameterValues.Limit]
        
        // 2. Build the URL
        let urlString = ParseClient.Constants.BaseURLSecure + ParseClient.Methods.StudentLocation +
            Helpers.escapedParameters(methodParameters as [String : AnyObject])
        _ = URL(string: urlString)!
        
        // 3. Configure the request
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        request.addValue(ParseClient.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        // 4. Make the request
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(nil, ParseClient.Constants.FailedConnection)
                return
            }
            
            // 5. Parse the data
            Helpers.parseJSONWithCompletionHandler(data!) { result, error in
                
                if error != nil {
                    completionHandler(nil, error)
                    return
                }
                
                // 6. Use the data
                let studentsArray: [[String:AnyObject]] = (result?.value(forKey: "results") as? [[String:AnyObject]])!
                let studentsInfo: [StudentInfo] = StudentInfo.studentInfoFromResults(studentsArray)
                completionHandler(studentsInfo, nil)
            }
        }) 
        
        // 7. Start the request
        task.resume()
    }

}
