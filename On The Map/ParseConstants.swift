//
//  ParseConstants.swift
//  On The Map
//
//  Created by Ioannis Tornazakis on 22/4/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import Foundation

extension ParseClient {
    
    // MARK: - Constants
    
    struct Constants {
        static let BaseURLSecure: String        = "https://api.parse.com/1/classes/"
        static let ParseApplicationID: String   = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTAPIKey: String           = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let FailedConnection: String     = "Connection Failure"
        static let ParsingError: String         = "Cannot parse the student information"
    }
    
    // MARK: - Methods
    
    struct Methods {
        static let StudentLocation: String = "StudentLocation"
    }
    
    // MARK: - Parameter Keys
    
    struct ParameterKeys {
        static let Limit: String = "limit"
    }
    
    struct ParameterValues {
        static let Limit: Int = 100
        static let LimitMax: Int = 1000
        static let LimitToOne: Int = 1
    }
    
    // MARK: - JSON Response Keys
    
    struct JSONResponseKeys {
        static let Results: String      = "results"
        
        static let FirstName: String    = "firstName"
        static let LastName: String     = "lastName"
        
        static let ObjectID: String     = "objectId"
        static let UniqueKey: String    = "uniqueKey"

        static let Lat: String          = "latitude"
        static let Long: String         = "longitude"
        static let MediaURL: String     = "mediaURL"
        static let MapString: String    = "mapString"
        
        static let CreatedAt: String    = "createdAt"
        static let UpdatedAt: String    = "updatedAt"
    }
    
}
