//
//  LoginViewController.swift
//  On The Map
//
//  Created by Ioannis Tornazakis on 20/4/15.
//  Copyright (c) 2015 polarbear.gr. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Properties
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    // MARK: - Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clear the delegate temp variables on init and after each logout
        self.resetAppDelegate()
        
        // Configure the tap recocnizer
        self.setTapRecognizer()
    }
    
    // MARK: - Actions
    
    @IBAction func loginButtonTouch(_ sender: AnyObject) {
        
        // Require username
        if emailTextField.text!.isEmpty {
            self.alertView(
                UdacityClient.AuthenticationStatus.LoginFailed,
                message: "Email is empty"
            )
            
        // Require password
        } else if passwordTextField.text!.isEmpty {
            self.alertView(
                UdacityClient.AuthenticationStatus.LoginFailed,
                message: "Password is empty"
            )
            
        // Authenticate
        } else {
            self.authenticate()
        }
    }
    
    /// Open Safari to the udacity link
    @IBAction func SignUpButtonTouch(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string:UdacityClient.Constants.UdacitySignUp)!)
    }
    
    // MARK: - Methods
    
    /// Clear the appDelegate variables after a logout occurs
    func resetAppDelegate() {
        
        // Get the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Reset the udacity student data
        appDelegate.key = ""
        appDelegate.firstName = ""
        appDelegate.lastName = ""
    }
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func setTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleSingleTap(_:)))
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    /// Authenticate against the Udacity API
    func authenticate() {
        UdacityClient.authenticate(emailTextField.text!, password: passwordTextField.text!) { success, errorString in
            if success == true {
                self.showMapAndTableTabbedView()
            } else if (errorString != nil) {
                self.alertView(
                    UdacityClient.AuthenticationStatus.LoginFailed,
                    message: errorString!
                )
            }
        }
    }
    
    func alertView(_ title: String, message: String) {
        DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let tryAgain = UIAlertAction(title: "Try again", style: .default, handler: nil)
            alertController.addAction(tryAgain)
            self.present(alertController, animated: true) {
                
                // Reset only the password field, most probable user mishap
                self.passwordTextField.text = ""
            }
        })
    }
    
    /// Segue to the "Map and Table Tabbed View" on the main thread (UIKit restriction)
    func showMapAndTableTabbedView() {
        DispatchQueue.main.async(execute: {
            let storyboard = UIStoryboard (name: "Main", bundle: nil)
            let nextVC = storyboard.instantiateViewController(withIdentifier: "MapAndTableTabbedView")
                as! UITabBarController
            self.present(nextVC, animated: false, completion: nil)
        })
    }
}
