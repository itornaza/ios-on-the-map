//
//  MapViewController.swift
//  On The Map
//
//  Created by Ioannis Tornazakis on 23/4/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Properties
    
    var annotations = [MKPointAnnotation]()
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The controler is set to be delegate to mapView on the Storyboard
        
        // Add right the bar buttons
        let infoPostingButton = UIBarButtonItem(image: UIImage(named: "Pin"), style: .Plain, target: self,
            action: "infoPosting"
        )
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self,
            action: "refreshStudents"
        )
        navigationItem.setRightBarButtonItems([refreshButton, infoPostingButton], animated: true)
     
        // Get the annotations and load them to the map
        self.getAnnotations()
    }
    
    // MARK: - Actions
    
    @IBAction func logout(sender: AnyObject) {
        self.segue("LoginViewController")
    }
    
    // MARK: - Methods
    
    func infoPosting() {
        self.segue("InformationPostingViewController")
    }
    
    func getAnnotations() {
        
        // Get the current student info
        ParseClient.getStudentData(){ result, error in
            if error != nil {
                self.alertView(error!)
            } else {
                
                // Assign it to the delegate in order to access it from the table as well
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                // Get the sudents info from using the Parse API
                appDelegate.studentsInfo = result!
                
                // Fill in the global annotations array with the student's info
                for student in appDelegate.studentsInfo {
                    
                    // Create the annotation
                    let annotation = MKPointAnnotation()
                    
                    // Set the annotation attributes from the StudentInfo struct
                    annotation.coordinate = student.coordinate
                    annotation.title = student.firstName + student.lastName
                    annotation.subtitle = student.mediaURL
                    
                    // Add it to the annotations array
                    self.annotations.append(annotation)
                }
                
                // Add the annotations to the map
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapView.addAnnotations(self.annotations)
                })
            }
        }
    }
    
    func refreshStudents() {
        
        // Remove the existing annotations
        self.mapView.removeAnnotations(self.annotations)
        
        // Empty the annotations array
        self.annotations = []
        
        // Get the new annotations
        self.getAnnotations()
    }
    
    func segue(nextVC: String) {
        dispatch_async(dispatch_get_main_queue(), {
            // Grab storyboard
            let storyboard = UIStoryboard (name: "Main", bundle: nil)
            
            // Get the destination controller from the storyboard id
            let nextVC = storyboard.instantiateViewControllerWithIdentifier(nextVC) 
            
            // Go to the destination controller
            self.presentViewController(nextVC, animated: true, completion: nil)
        })
    }
    
    func alertView(message: String) {
        dispatch_async(dispatch_get_main_queue(), {
            let alertController = UIAlertController(title: "Error!", message: message, preferredStyle: .Alert)
            let dismiss = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
            alertController.addAction(dismiss)
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    // MARK: - Map View Delegate
    
    // Put the "info button" on the right side of each pin
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // When the "info button" is tapped open Safari to the student's link
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
    }
    
}
