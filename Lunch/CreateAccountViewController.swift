//
//  CreateAccountViewController.swift
//  Lunch
//
//  Created by Spencer Amann on 8/1/15.
//  Copyright (c) 2015 Spencer Amann. All rights reserved.
//

import UIKit
import Parse

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmedPasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func createAccountButtonClick(sender: AnyObject) {
        let user = PFUser()
        user.username = userNameTextField.text ?? "no username"
        user.password = passwordTextField.text == confirmedPasswordTextField.text ? passwordTextField.text : "dont match"
        user.email = emailTextField.text ?? "no email"

        // other fields can be set if you want to save more information
        user["phone"] = "650-555-0000"

        user.signUpInBackgroundWithBlock { (succes: Bool, error:NSError?) -> Void in
            if error == nil {
                println("created \(self.userNameTextField.text) with password: \(self.passwordTextField.text)")
            }
        }
    }
}
