//
//  GameScene.swift
//  TapCars
//

import SpriteKit
import GameplayKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var rightCar = SKSpriteNode()

    var canMove = false
    var rightCarToMoveRight = true
    
    var rightCarAtLeft = false
    var centerPoint : CGFloat!
    var score = 0

    
    let rightCarMinimumX :CGFloat = -150
    let rightCarMaximumX :CGFloat = 180
    
    var countDown = 1
    var stopEverything = true
    var scoreText = SKLabelNode()
    
    var gameSettings = Settings.sharedInstance
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setUp()
        physicsWorld.contactDelegate = self
        Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(GameScene.createRoadStrip), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameScene.startCountDown), userInfo: nil, repeats: true)
        
        Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 0.8, secondNumber: 1.8)), target: self, selector: #selector(GameScene.rightTraffic), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.removeItems), userInfo: nil, repeats: true)
        let deadTime = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: deadTime) { 
            Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameScene.increaseScore), userInfo: nil, repeats: true)
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if canMove{
            moveRightCar(rightSide: rightCarToMoveRight)
        }
        showRoadStrip()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "leftCar" || contact.bodyA.node?.name == "rightCar"{
        firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        firstBody.node?.removeFromParent()
        afterCollision()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            if touchLocation.x > centerPoint{
                if rightCarAtLeft{
                    rightCarAtLeft = false
                    rightCarToMoveRight = true
                }else{
                    rightCarAtLeft = true
                    rightCarToMoveRight = false
                }
            }
            canMove = true
        }
    }
    
    func setUp(){
        rightCar = self.childNode(withName: "rightCar") as! SKSpriteNode
        centerPoint = self.frame.size.width / self.frame.size.height
        
        rightCar.physicsBody?.categoryBitMask = ColliderType.CAR_COLLIDER
        rightCar.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER_1
        rightCar.physicsBody?.collisionBitMask = 0
        
        let scoreBackGround = SKShapeNode(rect:CGRect(x:-self.size.width/2 + 70 ,y:self.size.height/2 - 130 ,width:180,height:80), cornerRadius: 20)
        scoreBackGround.zPosition = 4
        scoreBackGround.fillColor = SKColor.black.withAlphaComponent(0.3)
        scoreBackGround.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(scoreBackGround)
        
        scoreText.name = "score"
        scoreText.fontName = "AvenirNext-Bold"
        scoreText.text = "0"
        scoreText.fontColor = SKColor.white
        scoreText.position = CGPoint(x: -self.size.width/2 + 160, y: self.size.height/2 - 110)
        scoreText.fontSize = 50
        scoreText.zPosition = 4
        addChild(scoreText)
    }
    
    func createRoadStrip(){
        let rightRoadStrip = SKShapeNode(rectOf: CGSize(width: 50, height: 50))
        rightRoadStrip.strokeColor = SKColor.white
        rightRoadStrip.fillColor = SKColor.white
        rightRoadStrip.alpha = 0.4
        rightRoadStrip.name = "rightRoadStrip"
        rightRoadStrip.zPosition = 10
        rightRoadStrip.position.x = 0
        rightRoadStrip.position.y = 700
        addChild(rightRoadStrip)
    }
    
    func showRoadStrip(){
        
        
        enumerateChildNodes(withName: "rightRoadStrip", using: { (roadStrip, stop) in
            let strip = roadStrip as! SKShapeNode
            strip.position.y -= 30
        })
        
        
        enumerateChildNodes(withName: "greenCar", using: { (rightCar, stop) in
            let car = rightCar as! SKSpriteNode
            car.position.y -= 15
        })

    }
    
    func removeItems(){
        for child in children{
            if child.position.y < -self.size.height - 100{
                child.removeFromParent()
            }
        }
        
    }
    
    func moveRightCar(rightSide:Bool){
        if rightSide{
            rightCar.position.x += 15
            if rightCar.position.x > rightCarMaximumX{
                rightCar.position.x = rightCarMaximumX
            }
        }else{
            rightCar.position.x -= 15
            if rightCar.position.x < rightCarMinimumX{
                rightCar.position.x = rightCarMinimumX

        }
     }
    }
    
    
    func rightTraffic(){
        if !stopEverything{
        let rightTrafficItem : SKSpriteNode!
        let randonNumber = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 8)
        switch Int(randonNumber) {
        case 1...4:
            rightTrafficItem = SKSpriteNode(imageNamed: "orangeCar")
            rightTrafficItem.name = "orangeCar"
            break
        case 5...8:
            rightTrafficItem = SKSpriteNode(imageNamed: "greenCar")
            rightTrafficItem.name = "greenCar"
            break
        default:
            rightTrafficItem = SKSpriteNode(imageNamed: "orangCar")
            rightTrafficItem.name = "orangeCar"
        }
        rightTrafficItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        rightTrafficItem.zPosition = 10
        let randomNum = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 15)
        switch Int(randomNum) {
        case 1...3:
            rightTrafficItem.position.x = 100
            break
        case 4...6:
            rightTrafficItem.position.x = 200
            break
        case 7...9:
            rightTrafficItem.position.x = -200
            break
        case 10...12:
            rightTrafficItem.position.x = 0
            break
        case 13...15:
            rightTrafficItem.position.x = -100
            break
        default:
            rightTrafficItem.position.x = -100
        }
        rightTrafficItem.position.y = 900
        rightTrafficItem.position.y = 900
        rightTrafficItem.physicsBody = SKPhysicsBody(circleOfRadius: rightTrafficItem.size.height/2)
        rightTrafficItem.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER_1
        rightTrafficItem.physicsBody?.collisionBitMask = 0
        rightTrafficItem.physicsBody?.affectedByGravity = false
        addChild(rightTrafficItem)
        }
    }
    
    func afterCollision(){
        if gameSettings.highScore < score{
            gameSettings.highScore = score
        }
        let menuScene = SKScene(fileNamed: "GameMenu")!
        menuScene.scaleMode = .aspectFill
        view?.presentScene(menuScene, transition: SKTransition.doorsCloseHorizontal(withDuration: TimeInterval(2)))
    }
    
    
    func startCountDown(){
        if countDown>0{
            if countDown < 4{
                let countDownLabel = SKLabelNode()
                countDownLabel.fontName = "AvenirNext-Bold"
                countDownLabel.fontColor = SKColor.white
                countDownLabel.fontSize = 300
                countDownLabel.text = String(countDown)
                countDownLabel.position = CGPoint(x: 0, y: 0)
                countDownLabel.zPosition = 300
                countDownLabel.name = "cLabel"
                countDownLabel.horizontalAlignmentMode = .center
                addChild(countDownLabel)
                
                let deadTime = DispatchTime.now() + 0.5
                DispatchQueue.main.asyncAfter(deadline: deadTime, execute: { 
                    countDownLabel.removeFromParent()
                })
            }
            countDown += 1
            if countDown == 4 {
                self.stopEverything = false
            }
        }
    }
    
    func increaseScore(){
        if !stopEverything{
            score += 1
            scoreText.text = String(score)
        }
    }
}
