//
//  ComposedViewController.swift
//  messagingapp
//
//  Created by Shan Lin on 4/15/17.
//  Copyright © 2017 Shan Lin. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ComposedViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    var ref: FIRDatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = FIRDatabase.database().reference()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func addPost(_ sender: Any)
    {
        // post data to firebase
        ref?.child("Posts").childByAutoId().setValue(textView.text)

        // dismiss popover
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPost(_ sender: Any)
    {
        // dismiss popover
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
