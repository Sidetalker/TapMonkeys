//
//  ViewController.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/8/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import QuartzCore

class TapViewController: UIViewController, PopLabelDelegate {
    @IBOutlet weak var tapLabel: UILabel!
    @IBOutlet weak var dataHeader: DataHeader!
    
    var genLabels = [PopLabel]()
    var genPoints = [CGPoint]()
    var gen = [String]()
    var letterCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        let nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName("updateHeaders", object: self, userInfo: [
            "letters" : 0,
            "animated" : true
            ])
    }
    
    func configure() {
        configureInterface()
        configureGestureRecognizers()
    }
    
    func configureInterface() {
        let tabBar = self.tabBarController as! TabBarController
        let saveData = load(self.tabBarController)
        
        if saveData.stage > 0 {
            tapLabel.alpha = 0.0
        }
        if saveData.stage == 1 {
            self.prepGen(0)
        }
        if saveData.stage == 2 {
            tabBar.setTabBarVisible(true, animated: true)
            tabBar.viewControllers![1].tabBarItem?.badgeValue = "!"
            
            self.prepGen(1)
        }
    }
    
    func configureGestureRecognizers() {
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("singleTapMain:"))
        let tapHold = UILongPressGestureRecognizer(target: self, action: Selector("holdMain:"))
        
        self.view.addGestureRecognizer(singleTap)
        self.view.addGestureRecognizer(tapHold)
    }
    
    func prepGen(index: Int) {
        gen = gens[index]
        genPoints = [CGPoint]()
        genLabels = [PopLabel]()
        
        let tabBar = self.tabBarController as! TabBarController
        let genWidth = CGFloat(count(gen) * 28)
        let gapWidth = self.view.frame.width - genWidth
        let frameMod = gapWidth / CGFloat((count(gen) + 1))
        let size = CGSize(width: 28, height: 28)
        let yLoc: CGFloat = (self.view.frame.height - tabBar.tabBarHeight()) / 2
        
        var curFrameMod = frameMod
        
        for letter in gen {
            genPoints.append(CGPoint(x: curFrameMod, y: yLoc))
            
            curFrameMod += frameMod + size.width
        }
    }
    
    func updateStage(newStage: Int) {
        var saveData = load(self.tabBarController)
        saveData.stage = newStage
        
        save(self.tabBarController, saveData)
    }
    
    func singleTapMain(sender: UITapGestureRecognizer) {
        let letter = alphabet[randomIntBetweenNumbers(0, 26)]
        let saveData = load(self.tabBarController)
        
        if saveData.stage == 0 {
            UIView.animateWithDuration(0.6, animations: { () -> Void in
                self.tapLabel.alpha = 0.0
                self.tapLabel.transform = CGAffineTransformMakeScale(1.35, 1.35)
                }, completion: { (Bool) -> Void in
                    self.updateStage(1)
                    self.prepGen(0)
            })
        }
        else if saveData.stage == 1 {
            let popLabel = popOne(sender.locationOfTouch(0, inView: self.view), letter: letter)
            
            if contains(gen, letter) {
                let index = find(gen, letter)!
                
                popLabel.pop(remove: false, customEnd: true, customPoint: genPoints[index], noEnd: false)
                
                gen.removeAtIndex(index)
                genPoints.removeAtIndex(index)
                genLabels.append(popLabel)
                
                if self.gen.count == 0 {
                    for i in 0...count(self.genLabels) - 1 {
                        delay(2.0 + Double(i) * 0.3, {
                            self.genLabels[i].pop(remove: true, customPoint: self.dataHeader.getCenterLetters())
                        })
                    }
                    
                    delay(2.0 + 0.3 * Double(count(self.genLabels) - 1), {
                        let tabBar = self.tabBarController as! TabBarController
                        
                        tabBar.setTabBarVisible(true, animated: true)
                        tabBar.viewControllers![1].tabBarItem?.badgeValue = "!"
                        
                        self.updateStage(2)
                        self.prepGen(1)
                    })
                }
            }
            else {
                popLabel.pop(remove: true, customPoint: self.dataHeader.getCenterLetters())
            }
        }
        else if saveData.stage == 5 {
            if count(gen) == 0 { prepGen(1) }
            
            let popLabel = popOne(sender.locationOfTouch(0, inView: self.view), letter: letter)
            
            if contains(gen, letter) {
                let index = find(gen, letter)!
                
                popLabel.pop(remove: false, customEnd: true, customPoint: genPoints[index], noEnd: false)
                
                gen.removeAtIndex(index)
                genPoints.removeAtIndex(index)
                genLabels.append(popLabel)
                
                if self.gen.count == 0 {
                    self.updateStage(6)
                    
                    for i in 0...count(self.genLabels) - 1 {
                        delay(2.0 + Double(i) * 0.3, {
                            self.genLabels[i].pop(remove: true, customPoint: self.dataHeader.getCenterLetters())
                        })
                    }
                    
                    delay(2.0 + 0.3 * Double(count(self.genLabels) - 1), {
                        let tabBar = self.tabBarController as! TabBarController
                        
                        tabBar.revealTab(2)
                        
                        tabBar.viewControllers![2].tabBarItem?.badgeValue = "!"
                    })
                }
            }
            else {
                popLabel.pop(remove: true, customPoint: self.dataHeader.getCenterLetters())
            }
        }
        else {
            let popLabel = popOne(sender.locationOfTouch(0, inView: self.view), letter: letter)
            
            popLabel.pop(remove: true, customPoint: self.dataHeader.getCenterLetters())
        }
    }
    
    func popOne(tapLoc: CGPoint, letter: String) -> PopLabel {
        let frame = CGRect(origin: CGPoint(x: tapLoc.x - 14, y: tapLoc.y - 14), size: CGSize(width: 28, height: 28))
        let popLabel = PopLabel(frame: frame, character: letter)
        
        popLabel.backgroundColor = UIColor.clearColor()
        popLabel.delegate = self
        
        self.view.addSubview(popLabel)
        
        return popLabel
    }
    
    func holdMain(sender: UILongPressGestureRecognizer) {
        
    }
    
    func finishedPopping(customEnd: Bool) {
        if customEnd { return }
        
        letterCount++
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName("updateHeaders", object: self, userInfo: [
            "letters" : 1,
            "animated" : true
        ])
    }
}



protocol PopLabelDelegate {
    func finishedPopping(customEnd: Bool)
}

class PopLabel: UIView {
    var delegate: PopLabelDelegate?
    var animator: UIDynamicAnimator?
    
    var index = 0
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, charIndex: Int) {
        super.init(frame: frame)
        
        setCharIndex(charIndex)
    }
    
    init(frame: CGRect, character: String) {
        super.init(frame: frame)
        
        setChar(character)
    }
    
    func setCharIndex(charIndex: Int) {
        index = charIndex
        
        setNeedsDisplay()
    }
    
    func setChar(character: String) {
        setCharIndex(find(alphabet, character)!)
    }
    
    override func drawRect(rect: CGRect) {
        TapStyle.drawMainLetter(character: alphabet[index])
    }
    
    func move(location: CGPoint, scale: CGFloat, alpha: CGFloat, duration: NSTimeInterval, delay: NSTimeInterval, remove: Bool) {
        UIView.animateWithDuration(duration, delay: delay, options: nil, animations: { () -> Void in
            self.frame = CGRect(origin: location, size: self.frame.size)
            self.alpha = alpha
            self.transform = CGAffineTransformMakeScale(scale, scale)
            }, completion: { (Bool) -> Void in
                if remove { self.removeFromSuperview() }
        })
    }
    
    func grow(scale: CGFloat = 1.3, alpha: CGFloat = 0.0, duration: NSTimeInterval = 0.3, delay: NSTimeInterval = 0.0, remove: Bool = true) {
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(scale, scale)
            self.alpha = alpha
            }, completion: { Bool -> Void in
                if remove { self.removeFromSuperview() }
        })
    }
    
    func pop(remove: Bool = true, customEnd: Bool = false, customPoint: CGPoint = CGPointZero, noEnd: Bool = false) {
        if self.superview == nil { return }
        
        // Angular velocity max and min
        let minAngularVelocity: CGFloat = 0.2
        let maxAngularVelocity: CGFloat = 0.8
        
        // Burst direction max and min
        let minDirection: CGFloat = 10
        let maxDirection: CGFloat = 70
        let minHeight: CGFloat = 250
        let maxHeight: CGFloat = 450
        
        // Growth scale
        let minScale: CGFloat = 0.5
        let maxScale: CGFloat = 0.5
        
        // Timing variables
        let fadeDelay = 0.0
        let fadeTime = 0.4
        let gravityWeight: CGFloat = 0.5
        
        // Calculate animation variables
        var curAngularity = randomFloatBetweenNumbers(minAngularVelocity, maxAngularVelocity)
        let curScale = randomFloatBetweenNumbers(minScale, maxScale)
        let curHeight = -randomFloatBetweenNumbers(minHeight, maxHeight)
        var curLinearity = CGPoint(x: randomFloatBetweenNumbers(minDirection, maxDirection), y: curHeight)
        
        if randomIntBetweenNumbers(0, 10) % 2 == 1 {
            curAngularity = -curAngularity
        }
        
        if randomIntBetweenNumbers(0, 10) % 2 == 1 {
            curLinearity = CGPoint(x: -curLinearity.x, y: curHeight)
        }
        
        // Set up the gravitronator
        let gravity = UIGravityBehavior(items: [self])
        let velocity = UIDynamicItemBehavior(items: [self])
        let collision = UICollisionBehavior(items: [self])
        
        gravity.gravityDirection = CGVectorMake(0, gravityWeight)
        collision.translatesReferenceBoundsIntoBoundary = true
        
        velocity.addAngularVelocity(curAngularity, forItem: self)
        velocity.addLinearVelocity(curLinearity, forItem: self)
        
        animator = UIDynamicAnimator(referenceView:self.superview!)
        animator?.addBehavior(gravity)
        animator?.addBehavior(velocity)
        animator?.addBehavior(collision)
        
        if noEnd { return }
        
        delay(0.8, {
            self.animator?.removeAllBehaviors()
            
            // Scale and fade
            UIView.animateWithDuration(0.4, delay: 0.0, options: nil, animations: {
                self.layer.transform = customEnd ? CATransform3DMakeScale(1.4, 1.4, 1.4) : CATransform3DIdentity
                self.frame = CGRect(origin: customPoint, size: CGSize(width: 28, height: 28))
                self.alpha = customEnd ? 1.0 : 0.0
                }, completion: { (Bool) -> Void in
                    self.delegate?.finishedPopping(customEnd)
                    if remove { self.removeFromSuperview() }
            })
        })
        
    }
}