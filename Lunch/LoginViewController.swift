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

    let loginIdentifier = "loginWithUsername"
    let createAccountIdentififer = "createAccount"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }

    @IBAction func loginButtonClick(sender: AnyObject) {
        if let username = userNameTextField.text, password = passwordTextField.text {
            PFUser.logInWithUsernameInBackground(username, password: password, block: { (user: PFUser?, error:NSError?) -> Void in
                if user != nil && error == nil {
                    self.performSegueWithIdentifier(self.loginIdentifier, sender: self)
                } else {
                    let notPermitted = UIAlertView(title: "Error", message: "Login Failed. \nWhoops!", delegate: nil, cancelButtonTitle: "OK")
                    notPermitted.show()
                }
            })
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == loginIdentifier {
            println("logged in")
        } else if segue.identifier == createAccountIdentififer {
            println("create account")
        }
    }
}