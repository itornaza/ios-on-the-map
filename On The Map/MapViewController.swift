//
//  MapViewController.swift
//  On The Map
//
//  Created by Ioannis Tornazakis on 23/4/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: - Properties
    
    var annotations = [MKPointAnnotation]()
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The controler is set to be delegate to mapView on the Storyboard
        
        // Add right the bar buttons
        let infoPostingButton = UIBarButtonItem(image: UIImage(named: "Pin"), style: .plain, target: self,
            action: #selector(MapViewController.infoPosting)
        )
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self,
            action: #selector(MapViewController.refreshStudents)
        )
        navigationItem.setRightBarButtonItems([refreshButton, infoPostingButton], animated: true)
     
        // Get the annotations and load them to the map
        self.getAnnotations()
    }
    
    // MARK: - Actions
    
    @IBAction func logout(_ sender: AnyObject) {
        self.segue("LoginViewController")
    }
    
    // MARK: - Helpers
    
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
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                
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
                DispatchQueue.main.async(execute: {
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
    
    // MARK: - Segues and Alerts
    
    func segue(_ nextVC: String) {
        DispatchQueue.main.async(execute: {
            // Grab storyboard
            let storyboard = UIStoryboard (name: "Main", bundle: nil)
            // Get the destination controller from the storyboard id
            let nextVC = storyboard.instantiateViewController(withIdentifier: nextVC)
            // Go to the destination controller
            self.present(nextVC, animated: true, completion: nil)
        })
    }
    
    func alertView(_ message: String) {
        DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alertController.addAction(dismiss)
            self.present(alertController, animated: true, completion: nil)
        })
    }
}

extension MapViewController: MKMapViewDelegate {

    // Put the "info button" on the right side of each pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    // When the "info button" is tapped open Safari to the student's link
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.shared
            app.openURL(URL(string: annotationView.annotation!.subtitle!!)!)
        }
    }
}
