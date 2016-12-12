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
    var studentLink: URL!
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
    
    @IBAction func findOnTheMapButtonTouch(_ sender: AnyObject) {
        
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
                let mapCamera = MKMapCamera(lookingAtCenter: self.annotation.coordinate,
                    fromEyeCoordinate: self.annotation.coordinate, eyeAltitude: 1000)
                self.mapView.setCamera(mapCamera, animated: true)
                
                // Configure UI for the next step
                self.configStep2()
            }

            // Stop the activity indicator view
            spinner.stopAnimating()
            self.configAfterActivity()
        } as! CLGeocodeCompletionHandler)
        
    }
    
    @IBAction func submitButtonTouch(_ sender: AnyObject) {
        
        // Check if the student link is valid
        if !self.validateUrl(self.studentLinkTextArea.text) {
            self.alertView("Validation failed", message: "Invalid URL: \(self.studentLinkTextArea.text)")
        } else {
            
            // Capture the student's link
            self.studentLink = URL(string: self.studentLinkTextArea.text)!
            
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
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func setTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(InformationPostingViewController.handleSingleTap(_:)))
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    // MARK: - Helpers
    
    /// Initializes the activity indicator view "spinner"
    func initSpinner() -> UIActivityIndicatorView {
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(
            activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge
        )
        spinner.center = self.view.center
        spinner.startAnimating()
        self.view.addSubview(spinner)
        
        return spinner
    }
    
    /// URL validator
    func validateUrl(_ url: String) -> Bool {
        let pattern = "^(https?:\\/\\/)([a-zA-Z0-9_\\-~]+\\.)+[a-zA-Z0-9_\\-~\\/\\.]+$"
        if let _ = url.range(of: pattern, options: .regularExpression){
            return true
        } else {
            return false
        }
    }
    
    /// Displays the UI elements for the student's location input
    func configStep1() {
        
        // Show UI elements
        self.whereAreYouLabel.isHidden = false
        self.studyingLabel.isHidden = false
        self.todayLabel.isHidden = false
        self.geolocationStringTextArea.isHidden = false
        self.findOnTheMapButton.isHidden = false
        
        // Hide UI elements
        self.studentLinkTextArea.isHidden = true
        self.submitButton.isHidden = true
        self.mapView.isHidden = true
    }

    /// Displays the UI elements for the student link input
    func configStep2() {
        
        // Show UI elements
        self.whereAreYouLabel.isHidden = true
        self.studyingLabel.isHidden = true
        self.todayLabel.isHidden = true
        self.geolocationStringTextArea.isHidden = true
        self.findOnTheMapButton.isHidden = true
        
        // Hide UI elements
        self.studentLinkTextArea.isHidden = false
        self.submitButton.isHidden = false
        self.mapView.isHidden = false

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
        DispatchQueue.main.async(execute: {
            let storyboard = UIStoryboard (name: "Main", bundle: nil)
            let nextVC = storyboard.instantiateViewController(withIdentifier: "MapAndTableTabbedView")
                as! UITabBarController
            self.present(nextVC, animated: false, completion: nil)
        })
    }
    
    func alertView(_ title: String, message: String) {
        DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let tryAgain = UIAlertAction(title: "Try again", style: .default, handler: nil)
            alertController.addAction(tryAgain)
            self.present(alertController, animated: true, completion: nil)
        })
    }
}
