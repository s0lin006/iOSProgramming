//
//  Message.swift
//  SnapMessage
//
//  Created by Shan Lin on 4/21/17.
//  Copyright © 2017 Shan Lin. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject
{

    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    func chatPartnerId() -> String?
    {
        if fromId == FIRAuth.auth()?.currentUser?.uid
        {
            return toId
        }
        else
        {
            return fromId
        }
    }


} // class



































