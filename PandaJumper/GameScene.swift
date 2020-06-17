//
//  GameScene.swift
//  PandaJumper
//
//  Created by Ankita Pabbi on 2020-06-16.
//  Copyright © 2020 Ankita Pabbi. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    let panda = SKSpriteNode(imageNamed: "myPanda1")
    
    let coin = SKSpriteNode(imageNamed: "coin")
    let playableRect: CGRect
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let pandaMove: SKAction
    let pandaMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    var lastTouchLocation : CGPoint?
    let pandaRotateRadiansPerSec:CGFloat = 4.0 * π
     var invincible = false
    var lives = 3
    var coins = 0
    var levels = 1
    var finalScore = 0
    var gameOver = false
    let livesLabel = SKLabelNode(fontNamed: "Chalkduster")
    let labelNode  = SKLabelNode(fontNamed: "Chalkduster")
    let coinLabel  = SKLabelNode(fontNamed: "Chalkduster")
    let levelLabel  = SKLabelNode(fontNamed: "Chalkduster")

    
    
    override init(size: CGSize) {
        panda.size = CGSize(width: 230, height: 230)
       
        coin.size = CGSize(width: 150, height: 150)
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight) // 4
     
        pandaMove = SKAction.moveBy(x: 1000 + panda.size.width, y: 0, duration: 2.5)
        super.init(size: size)
        // 5
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
       //backgroundColor = SKColor.black
                let background = SKSpriteNode(imageNamed: "bakground")
                background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
                background.position = CGPoint(x: size.width/2, y: size.height/2)
                // background.zRotation = CGFloat(M_PI) / 8
                background.zPosition = -1
                addChild(background)
        
                let mySize = background.size
                print("Size: \(mySize)")
        
        
                panda.position = CGPoint(x: 200, y: 210)
        
                coin.position = CGPoint(x: 950, y: 610)
                addChild(panda)
               spawnEnemy()
                addChild(coin)
                panda.run(SKAction.repeatForever(pandaMove))
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnEnemy()
                },
                               SKAction.wait(forDuration: 3.0)])))
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnExit()
                },
                               SKAction.wait(forDuration: 3.0)])))
        
//        run(SKAction.repeatForever(
//            SKAction.sequence([SKAction.run() { [weak self] in
//                self?.spawnCoin()
//                },
//                               SKAction.wait(forDuration: 1.0)])))
        
        
        livesLabel.text = "Lives: X"
        livesLabel.fontColor = SKColor.white
        livesLabel.fontSize = 100
        livesLabel.zPosition = 150
       
        livesLabel.position = CGPoint(
            x: -playableRect.size.width/2 + CGFloat(20),
            y: -playableRect.size.height/2 + CGFloat(20))
        addChild(livesLabel)
        
        labelNode.text = "Lives: \(lives)"
        labelNode.fontColor = SKColor.white
        labelNode.fontSize = 100
        labelNode.zPosition = 1300
        labelNode.position = CGPoint(x:300,
                                     y:1200)
        addChild(labelNode)
        coinLabel.text = "Coins: \(coins)"
        coinLabel.fontColor = SKColor.white
        coinLabel.fontSize = 100
        coinLabel.zPosition = 1300
        coinLabel.position = CGPoint(x:300,
                                     y:1000)
        addChild(coinLabel)
        levelLabel.text = "Level: \(levels)"
        levelLabel.fontColor = SKColor.white
        levelLabel.fontSize = 100
        levelLabel.zPosition = 1300
        levelLabel.position = CGPoint(x:1800,
                                     y:1200)
        addChild(levelLabel)
      // go()
        
    }
    func go(){
        
        
        let moveRight = SKAction.move(to: CGPoint(x: playableRect.width, y:  150), duration: 5)
        let moveLeft = moveRight.reversed()
        panda.run(SKAction.repeatForever(SKAction.sequence([moveRight, moveLeft])))
        
    }
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
//        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),
//                                   y: velocity.y * CGFloat(dt))
//        sprite.position += amountToMove
        run(SKAction.repeatForever(SKAction.run(){
            sprite.position.x += CGFloat(1000)
        }))
    }
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    
    func moveZombieToward(location: CGPoint) {
       
        let offset = CGPoint(x: location.x - panda.position.x,
                             y: location.y - panda.position.y)
        let length = sqrt(
            Double(offset.x * offset.x + offset.y * offset.y))
        let direction = CGPoint(x: offset.x / CGFloat(length),
                                y: offset.y / CGFloat(length))
        velocity = CGPoint(x: direction.x * pandaMovePointsPerSec, y: direction.y)
    }
    
    func sceneTouched(touchLocation:CGPoint) {
                lastTouchLocation = touchLocation
                moveZombieToward(location: touchLocation)
        
        let actionJump : SKAction
        actionJump = SKAction.moveBy(x: 0, y: 350, duration: 0.7)
        
        let jumpSequence = SKAction.sequence([actionJump, actionJump.reversed()])
        panda.run(jumpSequence)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    func boundsCheckPanda() {
        
        
      
        
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxY)
       
        if panda.position.x <= bottomLeft.x {
            panda.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if panda.position.x >= topRight.x {
            panda.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if panda.position.y <= bottomLeft.y {
            panda.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if panda.position.y >= topRight.y {
            panda.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    

    func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate * 180
    }
    
    func checkCollisions() {
        var hitCoin: [SKSpriteNode] = []
        enumerateChildNodes(withName: "coin") { node, _ in
            let coin = node as! SKSpriteNode
            if coin.frame.intersects(self.panda.frame) {
                hitCoin.append(coin)
            }
        }
        
        for coin in hitCoin {
            pandaHit(coin: coin)
        }
        
        if invincible {
            return
        }
        
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "spikes") { node, _ in
            let enemy = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 20).intersects(
                self.panda.frame) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            pandaHit(enemy: enemy)
        }
//        if invincible {
//            return
//        }
//
//        var hitEnemies: [SKSpriteNode] = []
//        enumerateChildNodes(withName: "spikes") { node, _ in
//            let enemy = node as! SKSpriteNode
//            if node.frame.insetBy(dx: 20, dy: 20).intersects(
//                self.panda.frame) {
//                hitEnemies.append(enemy)
//            }
//        }
//        for enemy in hitEnemies {
//            pandaHit(enemy: enemy)
//        }
    }
    func pandaHit(enemy: SKSpriteNode) {
        invincible = true
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(
                dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let setHidden = SKAction.run() { [weak self] in
            self?.panda.isHidden = false
            self?.invincible = false
        }
        panda.run(SKAction.sequence([blinkAction, setHidden]))
        lives -= 1
        
        
    }
    func pandaHit(coin: SKSpriteNode) {
       
        coin.removeAllActions()
        coin.setScale(1.0)
        coin.zRotation = 0
        
        let turnGreen = SKAction.colorize(with: SKColor.green, colorBlendFactor: 1.0, duration: 0.2)
        coin.run(turnGreen)
        
    }
    
    func spawnEnemy() {
        let spikes = SKSpriteNode(imageNamed: "spikes")
         spikes.size = CGSize(width: 240, height: 240)
        spikes.position = CGPoint(x: 800, y: 210)
//        spikes.position = CGPoint(
//            x: size.width + spikes.size.width/2,
//            y: CGFloat.random(
//                min: playableRect.minY + spikes.size.height/2,
//                max: playableRect.maxY - spikes.size.height/2))
        addChild(spikes)
//        spikes.name = "spikes"
//
//        let actionMove =
//            SKAction.moveTo(x: -spikes.size.width/2, duration: 2.0)
//        let actionRemove = SKAction.removeFromParent()
//        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        labelNode.text = "Lives: \(lives)"
        checkCollisions()
        
        
//        if lives <= 0 && !gameOver {
//            gameOver = true
//            print("You lose!")
//        }
        if lives <= 0 && !gameOver {
            gameOver = true
            print("You lose!")
            print("Your Final Score is " + String(finalScore))
            
            
            //if the user loses the game he will se the you Lose screen
            
            
            let gameOver = GameOverScreen(size: size, won: false)
            
            gameOver.scaleMode = scaleMode
            
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            
            view?.presentScene(gameOver, transition: reveal)
            
        } else if finalScore>=3 {
            print("You win!")
            print("Your Final Score is " + String(finalScore))
            
            
            //if the user wons the game he will se the you win screen
            
            
            let gameOver = GameOverScreen(size: size, won: true)
            gameOver.scaleMode = scaleMode
            
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            // 3
            view?.presentScene(gameOver, transition: reveal)
        }
            
            //        print("\(dt*1000) milliseconds since last update")
            //
            //        if let lastTouchLocation = lastTouchLocation {
            //            let diff = lastTouchLocation - panda.position
            //            if diff.length() <= pandaMovePointsPerSec * CGFloat(dt) {
            //                panda.position = lastTouchLocation
            //                velocity = CGPoint.zero
            //
            //            } else {
            //                move(sprite: panda, velocity: velocity)
            //              //rotate(sprite: panda, direction: velocity, rotateRadiansPerSec: pandaRotateRadiansPerSec)
            //            }
            //        }
            //
            boundsCheckPanda()
            
        
    }
    func spawnExit() {
        // 1
        let exit = SKSpriteNode(imageNamed: "exit")
        exit.size = CGSize(width: 150, height: 150)
        exit.name = "exit"
        exit.position = CGPoint(
            x: playableRect.maxX-100,
            y: playableRect.minY + 100)
        exit.zPosition = 50
        exit.setScale(0)
        addChild(exit)
        // 2
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        
        let actions = [appear]
    
        exit.run(SKAction.sequence(actions))
    }
    
    
}
