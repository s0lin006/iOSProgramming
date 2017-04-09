//
//  GameScene.swift
//  FlappyBirdKnockoff
//
//  Created by Shan Lin on 4/9/17.
//  Copyright © 2017 Shan Lin. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Layer: CGFloat
{
    case Background
    case Obstacle
    case Foreground
    case Player
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    let worldNode = SKNode()
    var playableStart: CGFloat = 0
    var playableHeight: CGFloat = 0
    let player = SKSpriteNode(imageNamed: "player1")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let gameGravity: CGFloat = -1500.0
    var playerVelocity = CGPoint.zero
    let impluse: CGFloat = 400
    let numForeground = 2
    let groundSpeed: CGFloat = 200
    let bottomObstacleMinFraction: CGFloat = 0.1
    let bottomObstacleMaxFraction: CGFloat = 0.6
    let gapMultiplier: CGFloat = 3.5

    override func didMove(to view: SKView)
    {
        addChild(worldNode)
        setupBackground()
        setupForeground()
        setupPlayer()
        spawnObstacle()
    }

    // MARK: Setup methods
    func setupBackground()
    {
        let background = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        background.position = CGPoint(x: size.width/2, y: size.height)
        background.zPosition = Layer.Background.rawValue
        worldNode.addChild(background)

        playableStart = size.height - background.size.height
        playableHeight = background.size.height
    }

    func setupForeground()
    {
        for i in 0..<numForeground
        {
            let foreground = SKSpriteNode(imageNamed: "floor")
            foreground.anchorPoint = CGPoint(x:0.0, y: 1.0)
            foreground.position = CGPoint(x: CGFloat(i)*foreground.size.width, y: playableStart)
            foreground.zPosition = Layer.Foreground.rawValue
            foreground.name = "foregrounds"
            worldNode.addChild(foreground)
        }
    }

    func setupPlayer()
    {
        player.size.width = player.size.width / 10
        player.size.height = player.size.height / 10
        player.position = CGPoint(x: size.width * 0.2, y: playableHeight * 0.4 + playableStart)
        player.zPosition = Layer.Player.rawValue
        worldNode.addChild(player)
    }

    // MARK: Gameplay
    func createObstacle() -> SKSpriteNode
    {
        let sprite = SKSpriteNode(imageNamed: "topPipe")
        sprite.zPosition = Layer.Obstacle.rawValue
        return sprite
    }

    func randomBetween(min: CGFloat, max: CGFloat) -> CGFloat
    {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * (max - min) + min
    }

    func spawnObstacle()
    {
        let bottomObstacle = createObstacle()
        let startX = size.width/2

        let bottomObstacleMin = (playableStart - bottomObstacle.size.height/2) + playableHeight * bottomObstacleMinFraction
        let bottomObstacleMax = (playableStart - bottomObstacle.size.height/2) + playableHeight * bottomObstacleMaxFraction
        bottomObstacle.position = CGPoint(x: startX, y: randomBetween(min: bottomObstacleMin, max: bottomObstacleMax))
        worldNode.addChild(bottomObstacle)

        let topObstacle = createObstacle()
        topObstacle.zRotation = 180 * .pi
        topObstacle.position = CGPoint(x: startX, y: bottomObstacle.position.y + bottomObstacle.size.height/2 + topObstacle.size.height/2 + player.size.height * gapMultiplier)
        worldNode.addChild(topObstacle)
    }

    func flapPlayer()
    {
        playerVelocity = CGPoint(x: 0, y: impluse)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        flapPlayer()
    }

    // MARK: Updates
    override func update(_ currentTime: TimeInterval)
    {
        if(lastUpdateTime > 0)
        {
            dt = currentTime - lastUpdateTime
        }
        else
        {
            dt = 0
        }
        lastUpdateTime = currentTime

        updatePlayer()
        updateForeground()
    }

    func updatePlayer()
    {
        // gravity
        let gravity = CGPoint(x: 0, y: gameGravity)
        let gravityStep = CGPoint(x: gravity.x * CGFloat(dt), y: gravity.y * CGFloat(dt))
        playerVelocity = CGPoint(x: playerVelocity.x + gravity.x, y: playerVelocity.y + gravityStep.y)

        // velocity
        let velocityStep = CGPoint(x: playerVelocity.x * CGFloat(dt), y: playerVelocity.y * CGFloat(dt))
        player.position = CGPoint(x: player.position.x + velocityStep.x, y: player.position.y + velocityStep.y)

        // temp check
        if(player.position.y - player.size.height/2 < playableStart)
        {
            player.position = CGPoint(x: player.position.x, y: playableStart + player.size.height/2)
        }
    }

    func updateForeground()
    {
        worldNode.enumerateChildNodes(withName: "foregrounds", using: { node, stop in
            if let foreground = node as? SKSpriteNode
            {
                print(foreground.position.x)
                let moveAmt = CGPoint(x: -self.groundSpeed * CGFloat(self.dt), y: 0)
                foreground.position = CGPoint(x: foreground.position.x + moveAmt.x, y: foreground.position.y + moveAmt.y)

                if(foreground.position.x < -foreground.size.width)
                {
                    foreground.position = CGPoint(x: foreground.position.x + foreground.size.width * CGFloat(self.numForeground), y: foreground.position.y)
                }
            }
        })
    }
}
