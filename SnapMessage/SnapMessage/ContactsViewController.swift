//
//  ViewController.swift
//  SnapMessage
//
//  Created by Shan Lin on 4/16/17.
//  Copyright © 2017 Shan Lin. All rights reserved.
//

import UIKit
import Firebase

class ContactsViewController: UIViewController
{

    @IBAction func logoutButton(_ sender: Any)
    {
        // user not logged in
        if FIRAuth.auth()?.currentUser?.uid == nil
        {
            handleLogout()
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    func handleLogout()
    {
        do
        {
            try FIRAuth.auth()?.signOut()
            print("Logged out")
        }
        catch let logoutError
        {
            print(logoutError)
        }
        let signinController = SignInViewController()
        present(signinController, animated: true, completion: nil)
    }


} // class





























