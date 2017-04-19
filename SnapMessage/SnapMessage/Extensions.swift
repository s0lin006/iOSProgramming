//
//  Extensions.swift
//  SnapMessage
//
//  Created by Shan Lin on 4/19/17.
//  Copyright © 2017 Shan Lin. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()


extension UIImageView
{

    func loadImageUsingCacheWithUrlString(urlString: String)
    {
        self.image = nil

        // check cache for img
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage
        {
            self.image = cachedImage
            return
        }

        // else download img
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in

            // download error
            if error != nil
            {
                print(error!)
                return
            }

            DispatchQueue.main.async
            {
                if let downloadedImage = UIImage(data: data!)
                {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)

                    self.image = downloadedImage
                }
            }
        }).resume()
    }



}






































