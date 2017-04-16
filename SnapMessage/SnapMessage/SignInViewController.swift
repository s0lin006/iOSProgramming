//
//  SignInViewController.swift
//  SnapMessage
//
//  Created by Shan Lin on 4/16/17.
//  Copyright © 2017 Shan Lin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignInViewController: UIViewController
{
    
    @IBOutlet weak var signinSelector: UISegmentedControl!
    @IBOutlet weak var signinLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!

    var isSignIn: Bool = true

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }


    @IBAction func signinSelectorChanged(_ sender: UISegmentedControl)
    {
        // flip bool value when segment change
        isSignIn = !isSignIn

        // set texts
        if isSignIn
        {
            signinLabel.text = "Sign In"
            signinButton.setTitle("Sign In", for: .normal)
        }
        else
        {
            signinLabel.text = "Register"
            signinButton.setTitle("Register", for: .normal)
        }
    }

    @IBAction func signinButtonTapped(_ sender: UIButton)
    {
        // check email and pass is not empty
        // TODO: Validation
        if let email = emailTextField.text, let pass = passwordTextField.text
        {
            if isSignIn
            {
                // sign in
                FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
                    if let u = user
                    {
                        // user found
                        self.performSegue(withIdentifier: "gotoHome", sender: self)
                    }
                    else
                    {
                        // error
                        self.alertUser(title: "Email or password is incorrect", message: "Email or password is incorrect, please try again or register")
                    }
                })
            }
            else
            {
                // register
                FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { (user, error) in
                    if let u = user
                    {
                        // add user to database
                        guard let uid = user?.uid else {
                            return
                        }
                        let ref = FIRDatabase.database().reference(fromURL: "https://snapmessage-db1ed.firebaseio.com/")
                        let usersReference = ref.child("users").child(uid)
                        let values = ["email" : self.emailTextField.text, "password" : self.passwordTextField.text]
                        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                            if err != nil
                            {
                                print(err)
                                return
                            }
                            print("Saved user success in database")
                        })


                        // user found, go to homescreen
                        self.performSegue(withIdentifier: "gotoHome", sender: self)
                    }
                    else
                    {
                        // error
                        self.alertUser(title: "Error", message: "Error in registering, please try again")
                    }
                })
            }
        }
    }

    func alertUser(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)

        present(alert, animated: true, completion: nil)
    }











} // class



































