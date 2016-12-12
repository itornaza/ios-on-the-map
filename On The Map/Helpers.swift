//
//  Helpers.swift
//  On The Map
//
//  Created by Ioannis Tornazakis on 22/4/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import Foundation

class Helpers: NSObject {
    
    /// Substitute the key for the value that is contained within the method name
    class func subtituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    /// Given raw JSON, return a usable Foundation object
    class func parseJSONWithCompletionHandler(_ data: Data,
        completionHandler: (_ result: AnyObject?, _ error: String?) -> Void) {
        
        var parsingError: NSError? = nil
        let parsedResult: AnyObject?
        do {
            parsedResult = try JSONSerialization.jsonObject(
                        with: data,
                        options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject?
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        // Set completion handler
        if let _ = parsingError {
            completionHandler(nil, ParseClient.Constants.ParsingError)
        } else {
            completionHandler(parsedResult, nil)
        }
    }
    
    /// Given a dictionary of parameters, convert to a string for a url
    class func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            
            // Make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.addingPercentEncoding(
                withAllowedCharacters: CharacterSet.urlQueryAllowed
            )
            
            // Append it
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
}
