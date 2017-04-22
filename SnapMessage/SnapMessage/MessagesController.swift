//
//  ViewController.swift
//  SnapMessage
//
//  Created by Shan Lin on 4/18/17.
//  Copyright © 2017 Shan Lin. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController
{
    let cellId = "cellId"

    override func viewDidLoad()
    {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handelLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleNewMessage))

        checkIfUserIsLoggedIn()

        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

    }

    var messages = [Message]()
    var messagesDictionary = [String: Message]()

    func observeUserMessages()
    {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else
        {
            return
        }

        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)

            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in

                if let dictionary = snapshot.value as? [String: AnyObject]
                {

                    let message = Message()
                    message.setValuesForKeys(dictionary)
                    self.messages.append(message)

                    if let chatPartnerId = message.chatPartnerId()
                    {
                        self.messagesDictionary[chatPartnerId] = message

                        self.messages = Array(self.messagesDictionary.values)

                        //sort array by time
                        self.messages.sort(by: { (message1, message2) -> Bool in

                            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
                        })
                    }

                    self.timer?.invalidate()
                    print("timer cancelled")
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                    print("table reload in 0.1")
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }

    var timer: Timer?

    func handleReloadTable()
    {
        print("table reloaded")
        // crash due to background thread. use dispatch async
        DispatchQueue.main.async
        {
            self.tableView.reloadData()
        }
    }

    func observeMessages()
    {
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in

            if let dictionary = snapshot.value as? [String: AnyObject]
            {

                let message = Message()
                message.setValuesForKeys(dictionary)
                self.messages.append(message)

                if let toId = message.toId
                {
                    self.messagesDictionary[toId] = message

                    self.messages = Array(self.messagesDictionary.values)

                    //sort array by time
                    self.messages.sort(by: { (message1, message2) -> Bool in

                        return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
                    })
                }

                // crash due to background thread. use dispatch async
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell

        let message = messages[indexPath.row]
        cell.message = message

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 72
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let message = messages[indexPath.row]

        guard let charPartnerId = message.chatPartnerId() else
        {
            return
        }

        let ref = FIRDatabase.database().reference().child("users").child(charPartnerId)
        ref.observe(.value, with: { (snapshot) in

            guard let dictionary = snapshot.value as? [String: AnyObject] else
            {
                return
            }

            let user = User()
            user.id = charPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user: user)

        }, withCancel: nil)
    }

    func handleNewMessage()
    {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }

    func checkIfUserIsLoggedIn()
    {
        // if user not logged in, logout
        if FIRAuth.auth()?.currentUser?.uid == nil
        {
            perform(#selector(handelLogout), with: nil, afterDelay: 0)
        }
        else
        {
            fetchUserAndSetupNavBarTitle()
        }
    }

    func fetchUserAndSetupNavBarTitle()
    {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else
        {
            // if uid is nil
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

            if let dictionary = snapshot.value as? [String: AnyObject]
            {
                self.navigationItem.title = dictionary["name"] as? String

                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: user)
            }


        })
    }

    func setupNavBarWithUser(user: User)
    {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()

        observeUserMessages()

        let titleView = UIView()

        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)

        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true

        if let profileImageUrl = user.profileImageUrl
        {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }

        containerView.addSubview(profileImageView)

        // x, y, width, height
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let nameLabel = UILabel()

        titleView.addSubview(nameLabel)

        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x, y, width, height
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true

        // container view
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true

        self.navigationItem.titleView = titleView

    }

    func showChatControllerForUser(user: User)
    {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
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
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }


} // class







































