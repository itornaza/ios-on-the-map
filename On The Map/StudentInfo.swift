//
//  StudentInfo.swift
//  On The Map
//
//  Created by Ioannis Tornazakis on 22/4/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import Foundation
import MapKit

struct StudentInfo {
    
    // MARK: - Properties
    
    var uniqueKey: String!
    var firstName: String!
    var lastName: String!
    var mediaURL: String!
    var coordinate: CLLocationCoordinate2D!
    
    // MARK: - Constructors
    
    /**
        Construct a StudentInfo from a dictionary
    */
    init(dictionary: [String:AnyObject]) {
        
        // Local variables
        var lat: CLLocationDegrees!
        var long: CLLocationDegrees!
        
        self.uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as? String
        self.firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as? String
        self.lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as? String
        self.mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as? String

        lat = dictionary[ParseClient.JSONResponseKeys.Lat] as? CLLocationDegrees
        long = dictionary[ParseClient.JSONResponseKeys.Long] as? CLLocationDegrees
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    // MARK: - Methods
    
    /**
        Given an array of dictionaries, convert them to an array of StudentInfo objects
    */
    static func studentInfoFromResults(results: [[String:AnyObject]]) -> [StudentInfo] {
        
        var studentsInfo = [StudentInfo]()
        
        for result in results {
            studentsInfo.append(StudentInfo(dictionary: result))
        }
        
        return studentsInfo
    }
}
