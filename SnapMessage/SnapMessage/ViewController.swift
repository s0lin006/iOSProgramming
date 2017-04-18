//
//  ViewController.swift
//  SnapMessage
//
//  Created by Shan Lin on 4/18/17.
//  Copyright © 2017 Shan Lin. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handelLogout))

        // if user not logged in
        if FIRAuth.auth()?.currentUser?.uid == nil
        {
            perform(#selector(handelLogout), with: nil, afterDelay: 0)
            handelLogout()
        }

    }

    func handelLogout()
    {
        do
        {
            try FIRAuth.auth()?.signOut()
        }
        catch let logoutError
        {
            print(logoutError)
        }

        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }


} // class








































