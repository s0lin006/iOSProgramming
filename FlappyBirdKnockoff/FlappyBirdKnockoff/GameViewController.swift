//
//  GameViewController.swift
//  FlappyBirdKnockoff
//
//  Created by Shan Lin on 4/9/17.
//  Copyright © 2017 Shan Lin. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let view = self.view as? SKView
        {
            if view.scene == nil
            {
                let aspectRatio = view.bounds.size.height / view.bounds.size.width
                let scene = GameScene(size:CGSize(width: 320, height: 320 * aspectRatio))

                view.showsFPS = true
                view.showsNodeCount = true
                view.showsPhysics = true
                view.ignoresSiblingOrder = true

                scene.scaleMode = .aspectFill

                view.presentScene(scene)
            }
        }
    }

    override var prefersStatusBarHidden: Bool
    {
            return true
    }
}
