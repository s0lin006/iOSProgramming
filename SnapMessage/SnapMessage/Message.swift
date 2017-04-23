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
    // added to init dictionary
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?

    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?

    var videoUrl: String?

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

    init(dictionary: [String: AnyObject])
    {
        super.init()

        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        toId = dictionary["toId"] as? String

        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber

        videoUrl = dictionary["videoUrl"] as? String
    }


} // class



































