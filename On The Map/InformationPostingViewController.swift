//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by Ioannis Tornazakis on 25/4/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import CoreLocation

class InformationPostingViewController: UIViewController {
    
    // MARK: - Properties
    
    var annotation = MKPointAnnotation()
    var studentLink = NSURL()
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    // MARK: - Outlets
    
    @IBOutlet weak var whereAreYouLabel: UILabel!
    @IBOutlet weak var studyingLabel: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var geolocationStringTextArea: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var studentLinkTextArea: UITextView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configStep1()
        self.setTapRecognizer()
    }
    
    // MARK: - Actions
    
    @IBAction func findOnTheMapButtonTouch(sender: AnyObject) {
        
        // Start the activity indicator view
        let spinner = self.initSpinner()
        self.configDuringActivity()
        
        // Perform the forward geolocation
        CLGeocoder().geocodeAddressString(self.geolocationStringTextArea.text, completionHandler: {
            (placemarks: [CLPlacemark]?, error: NSError?) in
            
            if error != nil || placemarks!.count == 0 {
                
                // Throw an alert view and stay on this step to allow re-entry
                self.alertView("Geolocation failed", message: "Invalid address")
                
            } else {
                
                // Get the first placemarks coordinates
                let placemark = placemarks![0] 
                
                // Assign the coordinates to the annotation
                self.annotation.coordinate.latitude = placemark.location!.coordinate.latitude
                self.annotation.coordinate.longitude = placemark.location!.coordinate.longitude
                
                // Add the annotation to the map
                self.mapView.addAnnotation(self.annotation)
                
                // Zoom the map near the student's annotation using the MKMapCamera
                let mapCamera = MKMapCamera(lookingAtCenterCoordinate: self.annotation.coordinate,
                    fromEyeCoordinate: self.annotation.coordinate, eyeAltitude: 1000)
                self.mapView.setCamera(mapCamera, animated: true)
                
                // Configure UI for the next step
                self.configStep2()
            }

            // Stop the activity indicator view
            spinner.stopAnimating()
            self.configAfterActivity()
        })
        
    }
    
    @IBAction func submitButtonTouch(sender: AnyObject) {
        
        // Check if the student link is valid.
        if !self.validateUrl(self.studentLinkTextArea.text) {
            self.alertView("Validation failed", message: "Invalid URL: \(self.studentLinkTextArea.text)")
        } else {
            
            // Capture the student's link
            self.studentLink = NSURL(string: self.studentLinkTextArea.text)!
            
            // Prepare post attributes
            let studentLink: String = self.studentLink.absoluteString
            let mapString: String = self.geolocationStringTextArea.text
            let latitude: Double = self.annotation.coordinate.latitude as Double
            let longitude: Double = self.annotation.coordinate.longitude as Double
            
            // POST the student data to the Parse API
            ParseClient.postStudentData(studentLink, mapString: mapString, latitude: latitude, longitude: longitude) {
                success, errorString in
                
                if errorString != nil {
                    self.alertView("Network error", message: errorString!)
                } else {
                    self.showMapAndTableView()
                }
            }
        }
    }
    
    // MARK: - Tap Handlers
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func setTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    // MARK: - Helpers
    
    /// Initializes the activity indicator view "spinner"
    func initSpinner() -> UIActivityIndicatorView {
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(
            activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge
        )
        spinner.center = self.view.center
        spinner.startAnimating()
        self.view.addSubview(spinner)
        
        return spinner
    }
    
    /// URL validator
    func validateUrl(url: String) -> Bool {
        let pattern = "^(https?:\\/\\/)([a-zA-Z0-9_\\-~]+\\.)+[a-zA-Z0-9_\\-~\\/\\.]+$"
        if let _ = url.rangeOfString(pattern, options: .RegularExpressionSearch){
            return true
        } else {
            return false
        }
    }
    
    /// Displays the UI elements for the student's location input
    func configStep1() {
        
        // Show UI elements
        self.whereAreYouLabel.hidden = false
        self.studyingLabel.hidden = false
        self.todayLabel.hidden = false
        self.geolocationStringTextArea.hidden = false
        self.findOnTheMapButton.hidden = false
        
        // Hide UI elements
        self.studentLinkTextArea.hidden = true
        self.submitButton.hidden = true
        self.mapView.hidden = true
    }

    /// Displays the UI elements for the student link input
    func configStep2() {
        
        // Show UI elements
        self.whereAreYouLabel.hidden = true
        self.studyingLabel.hidden = true
        self.todayLabel.hidden = true
        self.geolocationStringTextArea.hidden = true
        self.findOnTheMapButton.hidden = true
        
        // Hide UI elements
        self.studentLinkTextArea.hidden = false
        self.submitButton.hidden = false
        self.mapView.hidden = false

    }
    
    /// Dims UI elements during activity
    func configDuringActivity() {
        self.whereAreYouLabel.alpha = 0.5
        self.studyingLabel.alpha = 0.5
        self.todayLabel.alpha = 0.5
        self.geolocationStringTextArea.alpha = 0.5
        self.findOnTheMapButton.alpha = 0.5
    }
    
    /// Resets the full color of UI elements after activity completes
    func configAfterActivity() {
        self.whereAreYouLabel.alpha = 1.0
        self.studyingLabel.alpha = 1.0
        self.todayLabel.alpha = 1.0
        self.geolocationStringTextArea.alpha = 1.0
        self.findOnTheMapButton.alpha = 1.0
    }
    
    // MARK: - Segues and Alerts
    
    /// Segue to the Map and Table View
    func showMapAndTableView() {
        dispatch_async(dispatch_get_main_queue(), {
            // Grab storyboard
            let storyboard = UIStoryboard (name: "Main", bundle: nil)
            // Get the destination controller from the storyboard id
            let nextVC = storyboard.instantiateViewControllerWithIdentifier("MapAndTableTabbedView")
                as! UITabBarController
            // Go to the destination controller
            self.presentViewController(nextVC, animated: false, completion: nil)
        })
    }
    
    func alertView(title: String, message: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let tryAgain = UIAlertAction(title: "Try again", style: .Default, handler: nil)
            alertController.addAction(tryAgain)
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
}
