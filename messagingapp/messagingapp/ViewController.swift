//
//  ViewController.swift
//  messagingapp
//
//  Created by Shan Lin on 4/15/17.
//  Copyright © 2017 Shan Lin. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{

    @IBOutlet weak var tableView: UITableView!

    var ref:FIRDatabaseReference?
    var databaseHandle: FIRDatabaseHandle?

    var postData = [String]()


    override func viewDidLoad()
    {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        // set firebase reference
        ref = FIRDatabase.database().reference()

        // retrieve and listen
        databaseHandle = ref?.child("Posts").observe(.childAdded, with: { (snapshot) in
            // code to execute when added under posts
            // take value from snapshot and add to postdata array

            // try convert value of data to string
            let post = snapshot.value as? String

            if let actualPost = post
            {
                // append data to post data
                self.postData.append(actualPost)

                // reload table view
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return postData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell")
        cell?.textLabel?.text = postData[indexPath.row]
        return cell!
    }
}

