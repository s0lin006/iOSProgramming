//
//  LoginController+handlers.swift
//  SnapMessage
//
//  Created by Shan Lin on 4/19/17.
//  Copyright © 2017 Shan Lin. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

    func handleRegister()
    {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else
        {
            print("form is not valid")
            return
        }

        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            if error != nil
            {
                print(error!)
                return
            }

            guard let uid = user?.uid else
            {
                return
            }

            // user auth success
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).png")


            //if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!)

            //if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1)
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1)
            {
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil
                    {
                        print(error!)
                        return
                    }

                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString
                    {
                        let values = ["name" : name, "email" : email, "profileImageUrl" : profileImageUrl]

                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values)
                    }
                })
            }
        })
    }

    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any])
    {
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child("users").child(uid)

        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil
            {
                print(err!)
                return
            }

            //self.messagesController?.fetchUserAndSetupNavBarTitle()
            //self.messagesController?.navigationItem.title = values["name"] as? String

            let user = User()
            //setter will crash if keys dont match
            user.setValuesForKeys(values)
            self.messagesController?.setupNavBarWithUser(user: user)

            self.dismiss(animated: true, completion: nil)
        })
    }

    func handleSelectProfileImageView()
    {
        let picker = UIImagePickerController()

        picker.delegate = self
        picker.allowsEditing = true

        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

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
            profileImageView.image = selectedImage
        }

        dismiss(animated: true, completion: nil)

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("image pick cancel")
        dismiss(animated: true, completion: nil)
    }
}
