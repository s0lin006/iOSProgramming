//
//  GameScene.swift
//  FlappyBirdKnockoff
//
//  Created by Shan Lin on 4/9/17.
//  Copyright © 2017 Shan Lin. All rights reserved.
//
// http://bit.ly/1Lic6vd

import SpriteKit
import GameplayKit

enum Layer: CGFloat
{
    case Background
    case Obstacle
    case Foreground
    case Player
    case UI
}

enum GameState
{
    case MainMenu
    case Tutorial
    case Play
    case Falling
    case ShowingScore
    case GameOver
}

struct PhysicsCategory
{
    static let None:        uint = 0
    static let Player:      uint =      0b1 // 1
    static let Obstacle:    uint =     0b10 // 2
    static let Ground:      uint =    0b100 // 4
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
    let firstSpawnDelay: TimeInterval = 1.75
    let everySpawnDelay: TimeInterval = 1.5
    var hitGround = false
    var hitObstacle = false
    var gameState: GameState = .Play
    var scoreLabel: SKLabelNode!
    var score = 0
    let fontName = "AmericanTypewriter-Bold"
    let margin: CGFloat = 20.0

    override func didMove(to view: SKView)
    {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        addChild(worldNode)
        setupBackground()
        setupForeground()
        setupPlayer()
        startSpawning()
        setupLabel()

        flapPlayer()
        //flapPlayer()
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

        let lowerLeft = CGPoint(x: 0, y: playableStart)
        let lowerRight = CGPoint(x: size.width, y: playableStart)

        self.physicsBody = SKPhysicsBody(edgeFrom: lowerLeft, to: lowerRight)
        self.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player
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
        player.size.width = player.size.width
        player.size.height = player.size.height
        player.position = CGPoint(x: size.width * 0.2, y: playableHeight * 0.4 + playableStart)
        player.zPosition = Layer.Player.rawValue

        let offsetX = player.size.width * player.anchorPoint.x
        let offsetY = player.size.height * player.anchorPoint.y

        let path = CGMutablePath()

        //CGPathMoveToPoint(path, nil, 0 - offsetX, 3 - offsetY)
        //CGPathAddLineToPoint(path, nil, 19 - offsetX, 27 - offsetY)
        //CGPathAddLineToPoint(path, nil, 38 - offsetX, 3 - offsetY)
        //CGPathAddLineToPoint(path, nil, 0 - offsetX, 1 - offsetY)

        path.move(to: CGPoint(x: 0 - offsetX, y: 3 - offsetY))
        path.addLine(to: CGPoint(x: 19 - offsetX, y: 28 - offsetY))
        path.addLine(to: CGPoint(x: 37 - offsetX, y: 2 - offsetY))

        path.closeSubpath()
        
        player.physicsBody = SKPhysicsBody(polygonFrom: path)
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Obstacle | PhysicsCategory.Ground

        worldNode.addChild(player)
    }

    func setupLabel()
    {
        scoreLabel = SKLabelNode(fontNamed: fontName)
        scoreLabel.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height - margin)
        scoreLabel.text = "0"
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.zPosition = Layer.UI.rawValue
        worldNode.addChild(scoreLabel)
    }

    // MARK: Gameplay
    func createObstacle() -> SKSpriteNode
    {
        let sprite = SKSpriteNode(imageNamed: "topPipe")
        sprite.zPosition = Layer.Obstacle.rawValue

        sprite.userData = NSMutableDictionary()

        let offsetX = sprite.size.width * sprite.anchorPoint.x
        let offsetY = sprite.size.height * sprite.anchorPoint.y

        let path = CGMutablePath()

        path.move(to: CGPoint(x: 0 - offsetX, y: 0 - offsetY))
        path.addLine(to: CGPoint(x: 0 - offsetX, y: 315 - offsetY))
        path.addLine(to: CGPoint(x: 53 - offsetX, y: 315 - offsetY))
        path.addLine(to: CGPoint(x: 53 - offsetX, y: 0 - offsetY))
        
        path.closeSubpath();

        sprite.physicsBody = SKPhysicsBody(polygonFrom: path)
        sprite.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
        sprite.physicsBody?.collisionBitMask = 0
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.Player

        return sprite
    }

    func randomBetween(min: CGFloat, max: CGFloat) -> CGFloat
    {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * (max - min) + min
    }

    func spawnObstacle()
    {
        let bottomObstacle = createObstacle()
        let startX = size.width + bottomObstacle.size.width/2

        let bottomObstacleMin = (playableStart - bottomObstacle.size.height/2) + playableHeight * bottomObstacleMinFraction
        let bottomObstacleMax = (playableStart - bottomObstacle.size.height/2) + playableHeight * bottomObstacleMaxFraction
        bottomObstacle.position = CGPoint(x: startX, y: randomBetween(min: bottomObstacleMin, max: bottomObstacleMax))
        bottomObstacle.name = "BottomObstacle"
        worldNode.addChild(bottomObstacle)

        let topObstacle = createObstacle()
        topObstacle.zRotation = 180 * .pi
        topObstacle.position = CGPoint(x: startX, y: bottomObstacle.position.y + bottomObstacle.size.height/2 + topObstacle.size.height/2 + player.size.height * gapMultiplier)
        topObstacle.name = "TopObstacle"
        worldNode.addChild(topObstacle)

        let moveX = size.width + topObstacle.size.width
        let moveDuration = moveX / groundSpeed
        let sequence = SKAction.sequence([SKAction.moveBy(x: -moveX, y: 0, duration: TimeInterval(moveDuration)),SKAction.removeFromParent()])
        topObstacle.run(sequence)
        bottomObstacle.run(sequence)
    }

    func startSpawning()
    {
        let firstDelay = SKAction.wait(forDuration: firstSpawnDelay)
        let spawn = SKAction.run(spawnObstacle)
        let everyDelay = SKAction.wait(forDuration: everySpawnDelay)
        let spawnSequence = SKAction.sequence([spawn, everyDelay])
        let foreverSpawn = SKAction.repeatForever(spawnSequence)
        let overallSequence = SKAction.sequence([firstDelay, foreverSpawn])
        run(overallSequence, withKey: "spawn")
    }

    func stopSpawning()
    {
        removeAction(forKey: "spawn")

        worldNode.enumerateChildNodes(withName: "TopObstacle", using: {node, stop in node.removeAllActions()})
        worldNode.enumerateChildNodes(withName: "BottomObstacle", using: {node, stop in node.removeAllActions()})
    }

    func flapPlayer()
    {
        playerVelocity = CGPoint(x: 0, y: impluse)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        switch gameState
        {
        case .MainMenu:
            break
        case .Tutorial:
            break
        case .Play:
            flapPlayer()
            break
        case .Falling:
            break
        case .ShowingScore:
            break
        case .GameOver:
            switchToNewGame()
            break
        }
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

        switch gameState
        {
            case .MainMenu:
                break
            case .Tutorial:
                break
            case .Play:
                updateForeground()
                updatePlayer()
                checkHitObstacle()
                checkHitGround()
                updateScore()
                break
            case .Falling:
                updatePlayer()
                checkHitGround()
                break
            case .ShowingScore:
                break
            case .GameOver:
                break
        }
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

    func setupScorecard()
    {
        if score > self.bestScore()
        {
            setBestScore(bestScore: score)
        }

        let scorecard = SKSpriteNode(imageNamed: "ScoreCard")
        scorecard.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        scorecard.name = "Tutorial"
        scorecard.zPosition = Layer.UI.rawValue
        worldNode.addChild(scorecard)

        let lastScore = SKLabelNode(fontNamed: fontName)
        lastScore.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        lastScore.position = CGPoint(x: -scorecard.size.width * 0.25, y: -scorecard.size.height * 0.2)
        lastScore.text = "\(score)"
        scorecard.addChild(lastScore)

        let bestScore = SKLabelNode(fontNamed: fontName)
        bestScore.fontColor = SKColor(red: 101.0/255.0, green: 71.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        bestScore.position = CGPoint(x: scorecard.size.width * 0.25, y: -scorecard.size.height * 0.2)
        bestScore.text = "\(self.bestScore())"
        scorecard.addChild(bestScore)

        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: size.width/2, y: size.height/2 + scorecard.size.height/2 + margin + gameOver.size.height/2)
        gameOver.zPosition = Layer.UI.rawValue
        worldNode.addChild(gameOver)

        let okButton = SKSpriteNode(imageNamed: "Button")
        okButton.position = CGPoint(x: size.width * 0.25, y: size.height/2 - scorecard.size.height/2 - margin - okButton.size.height/2)
        okButton.zPosition = Layer.UI.rawValue
        //worldNode.addChild(okButton)

        let ok = SKSpriteNode(imageNamed: "ok")
        ok.position = CGPoint(x: size.width * 0.25, y: size.height/2 - scorecard.size.height/2 - margin - okButton.size.height/2)
        ok.zPosition = Layer.UI.rawValue
        worldNode.addChild(ok)

        let shareButton = SKSpriteNode(imageNamed: "Button")
        shareButton.position = CGPoint(x: size.width * 0.75, y: size.height/2 - scorecard.size.height/2 - margin - shareButton.size.height/2)
        shareButton.zPosition = Layer.UI.rawValue
        //worldNode.addChild(shareButton)

        let share = SKSpriteNode(imageNamed: "share")
        share.position = CGPoint.zero
        share.zPosition = Layer.UI.rawValue
        shareButton.addChild(share)

        switchToGameOver()
    }

    func updateForeground()
    {
        worldNode.enumerateChildNodes(withName: "foregrounds", using: { node, stop in
            if let foreground = node as? SKSpriteNode
            {
                //print(foreground.position.x)
                let moveAmt = CGPoint(x: -self.groundSpeed * CGFloat(self.dt), y: 0)
                foreground.position = CGPoint(x: foreground.position.x + moveAmt.x, y: foreground.position.y + moveAmt.y)

                if(foreground.position.x < -foreground.size.width)
                {
                    foreground.position = CGPoint(x: foreground.position.x + foreground.size.width * CGFloat(self.numForeground), y: foreground.position.y)
                }
            }
        })
    }

    func checkHitObstacle()
    {
        if hitObstacle
        {
            hitObstacle = false
            switchToFalling()
        }
    }

    func checkHitGround()
    {
        if hitGround
        {
            hitGround = false
            playerVelocity = CGPoint.zero
            player.zRotation = 90 * .pi
            player.position = CGPoint(x: player.position.x, y: playableStart + player.size.width/2)
            switchToShowScore()
        }
    }

    func updateScore()
    {
        worldNode.enumerateChildNodes(withName: "BottomObstacle", using: {node, stop in
        if let obstacle = node as? SKSpriteNode
        {
            if let passed = obstacle.userData?["Passed"] as? NSNumber
            {
                if passed.boolValue
                {
                    return
                }
            }
            if self.player.position.x > obstacle.position.x + obstacle.size.width/2
            {
                self.score += 1
                self.scoreLabel.text = "\(self.score)"
                obstacle.userData?["Passed"] = NSNumber(value: true)
            }
        }
        })
    }

    // MARK: Game STates

    func switchToFalling()
    {
        gameState = .Falling

        player.removeAllActions()
        stopSpawning()
    }

    func switchToShowScore()
    {
        gameState = .ShowingScore

        player.removeAllActions()
        stopSpawning()
        setupScorecard()
    }

    func switchToNewGame()
    {
        let newScene = GameScene(size: size)
        let transition = SKTransition.fade(with: SKColor.black, duration: 0.5)
        view?.presentScene(newScene, transition: transition)
        gameState = .Play
    }

    func switchToGameOver()
    {
        gameState = .GameOver
    }

    // MARK: Score

    func bestScore() -> Int
    {
        return UserDefaults.standard.integer(forKey: "BestScore")
    }

    func setBestScore(bestScore: Int)
    {
        UserDefaults.standard.set(bestScore, forKey: "BestScore")
        UserDefaults.standard.synchronize()
    }

    // MARK: Physics
    func didBegin(_ contact: SKPhysicsContact)
    {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA

        if other.categoryBitMask == PhysicsCategory.Ground
        {
            hitGround = true
        }
        if other.categoryBitMask == PhysicsCategory.Obstacle
        {
            hitObstacle = true
        }
    }
}
