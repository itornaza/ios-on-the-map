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
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /// Given raw JSON, return a usable Foundation object
    class func parseJSONWithCompletionHandler(data: NSData,
        completionHandler: (result: AnyObject!, error: String?) -> Void) {
        
        var parsingError: NSError? = nil
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(
                        data,
                        options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        // Set completion handler
        if let _ = parsingError {
            completionHandler(result: nil, error: ParseClient.Constants.ParsingError)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /// Given a dictionary of parameters, convert to a string for a url
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            
            // Make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(
                NSCharacterSet.URLQueryAllowedCharacterSet()
            )
            
            // Append it
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
}