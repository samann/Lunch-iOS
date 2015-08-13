//
//  LoginViewController.swift
//  Lunch
//
//  Created by Spencer Amann on 8/1/15.
//  Copyright (c) 2015 Spencer Amann. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    let loginIdentifier = "loginSegue"
    let createAccountIdentifier = "createAccount"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let currentUser = PFUser.currentUser(), username = currentUser.username {
                self.performSegueWithIdentifier(self.loginIdentifier, sender: self)
        }
    }

    @IBAction func loginNavButtonTapped(sender: UIBarButtonItem) {
        if let username = userNameTextField.text, password = passwordTextField.text {
            PFUser.logInWithUsernameInBackground(username, password: password, block: { (user: PFUser?, error:NSError?) in
                if user != nil && error == nil {
                    self.performSegueWithIdentifier(self.loginIdentifier, sender: self)
                } else {
                    let alertView = UIAlertView(title: "Error", message: "Login Failed. \nWhoops!", delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                }
            })
        }

    }

    @IBAction func createAccountButtonTapped(sender: UIButton) {
        self.performSegueWithIdentifier(createAccountIdentifier, sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == loginIdentifier {
            println("logged in")
        } else if segue.identifier == createAccountIdentifier {
            println("create account")
        }
    }
}
