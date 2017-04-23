//
//  ChatLogController.swift
//  SnapMessage
//
//  Created by Shan Lin on 4/20/17.
//  Copyright © 2017 Shan Lin. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var user: User?
    {
        didSet
        {
            navigationItem.title = user?.name

            observeMessages()
        }
    }

    var messages = [Message]()

    func observeMessages()
    {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else
        {
            return
        }

        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in

            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in

                guard let dictionary = snapshot.value as? [String: AnyObject] else
                {
                    return
                }

                let message = Message(dictionary: dictionary)

                // will crash if keys dont match
                //message.setValuesForKeys(dictionary)

                self.messages.append(message)

                DispatchQueue.main.async
                {
                    self.collectionView?.reloadData()

                    //scroll to last index
                    let indexPath = NSIndexPath(item: self.messages.count - 1, section: 0) as IndexPath
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }

                // dont need check/filter anymore. Added new node structure in firebase db
//                if message.chatPartnerId() == self.user?.id
//                {
//                    self.messages.append(message)
//
//                    DispatchQueue.main.async
//                        {
//                            self.collectionView?.reloadData()
//                    }
//                }
            }, withCancel: nil)

        }, withCancel: nil)
    }

    lazy var inputTextField: UITextField =
    {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()

    let cellId = "cellId"

    override func viewDidLoad()
    {
        super.viewDidLoad()

        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        //collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)

        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)

        collectionView?.keyboardDismissMode = .interactive

        //setupInputComponents()
        setupKeyboardObservers()

    }

    lazy var inputContainerView: UIView =
    {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white

        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        // upload image view constraints x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true

        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)

        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        containerView.addSubview(self.inputTextField)

        // x,y,w,h
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor.init(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)

        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        return containerView
    }()

    func handleUploadTap()
    {
        let imagePickerController = UIImagePickerController()

        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]


        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        // selected video
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL
        {
            handleVideoSelectedForUrl(url: videoUrl)
        }
        else
        {
            // selected image
            handleImageSelectedForInfo(info: info as [String : AnyObject])
        }

        dismiss(animated: true, completion: nil)
    }

    private func handleVideoSelectedForUrl(url: NSURL)
    {
        let filename = NSUUID().uuidString + ".mov"

        let uploadTask = FIRStorage.storage().reference().child("message_movies").child(filename).putFile(url as URL, metadata: nil, completion: { (metadata, error) in

            if error != nil
            {
                print("failed to upload video")
                return
            }

            if let videoUrl = metadata?.downloadURL()?.absoluteString
            {

                if let thumbnailImage = self.thumbnailImageForVideoUrl(fileUrl: url)
                {
                    self.uploadToFirebaseStorageUsingImage(image: thumbnailImage, completion: { (imageUrl) in

                        let properties: [String: AnyObject] = ["imageUrl" : imageUrl as AnyObject, "imageWidth" : thumbnailImage.size.width as AnyObject, "imageHeight" : thumbnailImage.size.height as AnyObject, "videoUrl" : videoUrl as AnyObject]
                        self.sendMessageWithProperties(properties: properties)

                    })
                }
            }
        })

        uploadTask.observe(.progress, handler: { (snapshot)  in

            if let completedUnitCount = snapshot.progress?.completedUnitCount
            {
                self.navigationItem.title = String(completedUnitCount)
            }
        })

        uploadTask.observe(.success, handler: { (snapshot) in

            self.navigationItem.title = self.user?.name

        })
    }

    private func thumbnailImageForVideoUrl(fileUrl: NSURL) -> UIImage?
    {
        let asset = AVAsset(url: fileUrl as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do
        {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)

            return UIImage(cgImage: thumbnailCGImage)
        }
        catch let err
        {
            print(err)
        }

        return nil
    }

    private func handleImageSelectedForInfo(info: [String: AnyObject])
    {
        var selectedImageFromPicker: UIImage?

        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            selectedImageFromPicker = originalImage
        }

        if let selectedImage = selectedImageFromPicker
        {
            uploadToFirebaseStorageUsingImage(image: selectedImage, completion: { (imageUrl) in

                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)

            })
        }
    }

    private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ())
    {
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("message_images").child(imageName)

        if let uploadData = UIImageJPEGRepresentation(image, 0.2)
        {
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in

                if error != nil
                {
                    print("failed to upload image", error!)
                    return
                }

                if let imageUrl = metadata?.downloadURL()?.absoluteString
                {
                    completion(imageUrl)
                }

            })
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    override var inputAccessoryView: UIView?
    {
        get
        {
            return inputContainerView
        }
    }

    override var canBecomeFirstResponder: Bool
    {
        return true
    }

    func setupKeyboardObservers()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
//        // show keyboard
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//
//        // hide keyboard
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)

    }

    func handleKeyboardDidShow()
    {
        if messages.count > 0
        {
            let indexPath = NSIndexPath(item: messages.count - 1, section: 0) as IndexPath
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    func handleKeyboardWillShow(notification: NSNotification)
    {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        // move input up by keyboard height
        containterViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()

        })
    }

    func handleKeyboardWillHide(notification: NSNotification)
    {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue

        // move input down by keyboard height
        containterViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()

        })
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell

        cell.chatLogController = self

        let message = messages[indexPath.item]

        cell.message = message
        
        cell.textView.text = message.text

        setupCell(cell: cell, message: message)

        // bubble view width mod
        if let text = message.text
        {
            // if text message
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        }
        // if image message
        else if message.imageUrl != nil
        {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }

        if message.videoUrl != nil
        {
            cell.playButton.isHidden = false
        }
        else
        {
            cell.playButton.isHidden = true
        }

        return cell
    }

    private func setupCell(cell: ChatMessageCell, message: Message)
    {
        if let profileImageUrl = self.user?.profileImageUrl
        {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }

        if message.fromId == FIRAuth.auth()?.currentUser?.uid
        {
            // outgoing
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white

            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        }
        else
        {
            //incoming
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black

            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }

        // message image
        if let messageImageUrl = message.imageUrl
        {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        }
        else
        {
            cell.messageImageView.isHidden = true
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var height: CGFloat = 80

        let message = messages[indexPath.item]
        if let text = message.text
        {
            height = estimateFrameForText(text: text).height + 20
        }
        else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue
        {
            // setup proportion calculation h1 / w1 = h2 / w2
            // h1 = h2 / w2 * w1
            height = CGFloat(imageHeight / imageWidth * 200) // 200 =cell.bubbleWidthAnchor?.constant = 200
        }

        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }

    private func estimateFrameForText(text: String) -> CGRect
    {
        let size = CGSize(width: 200, height: 10000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)


        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }

    var containterViewBottomAnchor: NSLayoutConstraint?

    func setupInputComponents()
    {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(containerView)

        // constraints x,y,width,height
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true

        containterViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containterViewBottomAnchor?.isActive = true

        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)

        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        containerView.addSubview(inputTextField)

        // x,y,w,h
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor.init(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)

        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

    }

    func handleSend()
    {
        let properties: [String: Any] = ["text": inputTextField.text!]
        sendMessageWithProperties(properties: properties as [String : AnyObject])
    }

    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage)
    {
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth" : image.size.width as AnyObject, "imageHeight" : image.size.height as AnyObject]

        sendMessageWithProperties(properties: properties)
    }

    private func sendMessageWithProperties(properties: [String: AnyObject])
    {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid


        //let timestamp = NSDate().timeIntervalSince1970
        let timestamp = NSNumber(value: Int(NSDate().timeIntervalSince1970))


        var values: [String: AnyObject] = ["toId" : toId as AnyObject, "fromId" : fromId as AnyObject, "timestamp" : timestamp]

        // append properties dictionary onto values
        // key = $0, value = $1
        properties.forEach({values[$0] = $1})

        //childRef.updateChildValues(values)

        childRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
            if error != nil
            {
                print(error!)
                return
            }

            self.inputTextField.text = nil

            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)

            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])

            let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        })
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?

    // zooming images
    func performZoomInForStartingImageView(startingImageView: UIImageView)
    {
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true

        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)

        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        zoomingImageView.isUserInteractionEnabled = true

        if let keyWindow = UIApplication.shared.keyWindow
        {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)

            keyWindow.addSubview(zoomingImageView)

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                // rectangle proportion: h1/w1 = h2/w2
                // h2 = h1/w1 * w2
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width

                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center

            }, completion: { (completed: Bool) in

                // do nothing

            })
        }
    }

    func handleZoomOut(tapGesture: UITapGestureRecognizer)
    {
        // anomate back
        if let zoomOutImageView = tapGesture.view
        {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1

            }, completion: { (completed: Bool) in

                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }

} // class











































