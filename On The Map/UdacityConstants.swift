//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Ioannis Tornazakis on 21/4/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    // MARK: - Authentication Status
    
    struct AuthenticationStatus {
        static let Success: Bool = true
        static let Failure: Bool = false
        static let LoginFailed: String          = "Login failed"
        static let InvalidCredentials: String   = "Invalid Credentials"
        static let FailedConnection: String     = "Connection Failure"
        static let ParseError: String           = "Cannot parse the student information"
        static let StudentDataFailed: String    = "Could not retrieve first and last student's name"
    }
    
    struct Constants {
        static let BaseURLSecure: String = "https://www.udacity.com/api/"
        static let UdacitySignUp: String = "https://www.udacity.com/account/auth#!/signin"
    }
    
    // MARK: - Methods
    
    struct Methods {
        static let Session: String  = "session"
        static let Users: String    = "users"
    }
    
    // MARK: - Parameter Keys
    
    struct ParameterKeys {
        static let Email: String    = "username"
        static let Password: String = "password"
    }
    
    // MARK: - JSON Response Keys
    
    struct JSONResponseKeys {
        
        // MARK: - Timing
        static let CurrentTime: String              = "current_time"
        static let CurrentSecondsSinceEpoch: String = "current_seconds_since_epoch"
        
        // MARK: - Acount
        static let Account: String      = "account"
        static let Registered: String   = "registered"
        
        // MARK: - User
        static let User: String         = "user"
        static let Key: String          = "key"
        static let FirstName: String    = "first_name"
        static let LastName: String     = "last_name"
        
        // MARK: - Session
        static let Session: String      = "session"
        static let ID: String           = "id"
        static let Expiration: String   = "expiration"
        
        // MARK: - Error
        static let Error: String        = "error"
        static let Status: String       = "status"
        static let ErrorStatus: Int = 403
    }
}