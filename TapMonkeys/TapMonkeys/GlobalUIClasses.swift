//
//  GlobalUIClasses.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/13/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

enum ObjectType {
    case Monkey
    case Writing
    case Income
}

class ConstraintView: UIView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
    }
}

class AutoUpdateLabel: UILabel {
    var index = -1
    var controller: TabBarController?
    var type: ObjectType = .Monkey
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
         
        let timer = NSTimer.scheduledTimerWithTimeInterval(0.10, target: self, selector: Selector("refresh"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    func refresh() {
        if controller == nil { return }
        
        let saveData = load(controller!)
        
        if type == .Monkey {
            let total = generalFormatter.stringFromNumber(saveData.monkeyTotals![index])!
            
            self.text = "Total Letters: \(total)"
        }
        else if type == .Income {
            let amount = currencyFormatter.stringFromNumber(saveData.incomeTotals![index])!
            
            self.text = "Total: \(amount)"
        }
    }
}

protocol AnimatedLockDelegate {
    func tappedLock(view: AnimatedLockView)
}

class AnimatedLockView: UIView {
    @IBOutlet var nibView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lockImage: UIImageView!
    @IBOutlet weak var requirementsText: UILabel!
    @IBOutlet weak var staticText: UILabel!
    @IBOutlet weak var pic: UIImageView!
    
    var locked = true
    var type: ObjectType = .Monkey
    var index = -1
    var animator: UIDynamicAnimator?
    var delegate: AnimatedLockDelegate?
    var transitionView: UIView?
    var nightMode = false
    
    var lockImages = [UIImage]()
    var lockImagesNight = [UIImage]()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    func configure() {
        NSBundle.mainBundle().loadNibNamed("AnimatedLockView", owner: self, options: nil)
        
        nibView.frame = self.frame
        
        self.addSubview(nibView)
        
        transitionView = UIView(frame: self.frame)
        transitionView!.backgroundColor = UIColor.whiteColor()
        
        self.nibView.addSubview(transitionView!)
        self.nibView.sendSubviewToBack(transitionView!)
        self.nibView.bringSubviewToFront(lockImage)
        
        for i in 1...12 {
            let imageName = "animatedLock" + (NSString(format: "%02d", i) as String)
            let imageNameNight = "animatedLockNight" + (NSString(format: "%02d", i) as String)
            
            if let image = UIImage(named: imageName) {
                lockImages.append(image)
            }
            if let imageNight = UIImage(named: imageNameNight) {
                lockImagesNight.append(imageNight)
            }
        }
        
        lockImage.animationImages = nightMode ? lockImagesNight : lockImages
        lockImage.animationDuration = 0.35
        lockImage.animationRepeatCount = 1
        
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("lockTap:"))
        
        self.addGestureRecognizer(singleTap)
    }
    
    func customize(saveData: SaveData) {
        nightMode = saveData.nightMode!
        
        staticText.textColor = nightMode ? UIColor.lightTextColor() : UIColor.blackColor()
        requirementsText.textColor = nightMode ? UIColor.lightTextColor() : UIColor.blackColor()
        pic.alpha = nightMode ? 0.5 : 1.0
        lockImage.image = nightMode ? lockImagesNight[0] : lockImages[0]
        lockImage.animationImages = nightMode ? lockImagesNight : lockImages
        bgView.backgroundColor = nightMode ? UIColor.blackColor() : UIColor.whiteColor()
        
        if self.superview != nil {
            self.frame = self.superview!.frame
        }
        
        staticText.text = "Unlock With"
        
        if type == .Monkey {
            if index > 1 {
                if !saveData.monkeyUnlocks![index - 1] && !saveData.monkeyUnlocks![index - 2] {
                    requirementsText.text = "?????"
                    
                    pic.image = UIImage(named: "unknownUnlock")
                    
                    return
                }
            }
            
            let unlockIndex = Int(monkeys[index].unlockCost[0].0)
            let quantity = Int(monkeys[index].unlockCost[0].1)
            let plurarity = quantity > 1 ? "s" : ""
            
            requirementsText.text = "\(quantity) \(incomes[unlockIndex].name)\(plurarity)"
            
            if quantity == 0 {
                staticText.text = "Unlock For"
                requirementsText.text = "FREE"
            }
            
            pic.image = UIImage(named:monkeys[index].imageName)
        }
        else if type == .Writing {
            if index > 1 {
                if !saveData.writingUnlocked![index - 1] && !saveData.writingUnlocked![index - 2] {
                    requirementsText.text = "?????"
                    
                    pic.image = UIImage(named: "unknownUnlock")
                    
                    return
                }
            }
            
            requirementsText.text = "\(writings[index].unlockCost) Letters"
            
            if writings[index].unlockCost == 0 {
                staticText.text = "Unlock For"
                requirementsText.text = "FREE"
            }
            
            pic.image = UIImage(named:writings[index].imageName)
        }
        else if type == .Income {
            if index > 1 {
                if !saveData.incomeUnlocks![index - 1] && !saveData.incomeUnlocks![index - 2] {
                    requirementsText.text = "?????"
                    
                    pic.image = UIImage(named: "unknownUnlock")
                    
                    return
                }
            }
            
            let unlockIndex = Int(incomes[index].unlockCost[0].0)
            let quantity = Int(incomes[index].unlockCost[0].1)
            let plurarity = quantity > 1 ? "s" : ""
            
            requirementsText.text = "\(quantity) \(writings[unlockIndex].name)\(plurarity)"
            
            if quantity == 0 {
                staticText.text = "Unlock For"
                requirementsText.text = "FREE"
            }
            
            pic.image = UIImage(named:incomes[index].imageName)
        }
    }
    
    func lockTap(sender: UITapGestureRecognizer) {
        delegate?.tappedLock(self)
    }
    
    func unlock() {
        lockImage.image = nightMode ? UIImage(named: "animatedNightLock12") : UIImage(named: "animatedLock12")
        
        lockImage.startAnimating()
        
        let angularVelocityLock: CGFloat = 0.4
        let linearVelocityLock = CGPoint(x: 25, y: -150)
        
        // Set up the gravitronator
        let gravity = UIGravityBehavior(items: [lockImage])
        let velocity = UIDynamicItemBehavior(items: [lockImage])
        
        gravity.gravityDirection = CGVectorMake(0, 0.4)
        
        velocity.addAngularVelocity(angularVelocityLock, forItem: lockImage)
        velocity.addLinearVelocity(linearVelocityLock, forItem: lockImage)
        
        animator = UIDynamicAnimator(referenceView: self.nibView)
        animator?.addBehavior(velocity)
        animator?.addBehavior(gravity)
        
        UIView.animateWithDuration(0.66, delay: 0.0, options: nil, animations: { () -> Void in
            self.bgView.alpha = 0.0
            self.transitionView!.alpha = 0.0
            self.requirementsText.alpha = 0.0
            self.staticText.alpha = 0.0
            self.pic.alpha = 0.0
            }, completion: { (Bool) -> Void in
                
        })
        
        UIView.animateWithDuration(0.51, delay: 0.39, options: nil, animations: { () -> Void in
            self.lockImage.alpha = 0.0
            }, completion: { (Bool) -> Void in
                self.removeFromSuperview()
        })
    }
}

protocol DataHeaderDelegate {
    func toggleLight(sender: DataHeader)
}

//@IBDesignable class DataHeader: UIView {
class DataHeader: UIView {
    @IBOutlet var nibView: UIView!
    
    @IBOutlet weak var lightbulbButton: UIButton!
    @IBOutlet weak var lettersLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var wrapperView: UIView!
    
    var letters: Float = 0
    var money: Float = 0
    var nightMode = false
    var gonnaDisplayBulb = true
    
    var delegate: DataHeaderDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    @IBAction func tapLightbulb(sender: AnyObject) {
        delegate?.toggleLight(self)
    }
    
    func configure() {
        NSBundle.mainBundle().loadNibNamed("DataHeader", owner: self, options: nil)
        
        self.addSubview(nibView)
        
        nibView.frame = self.frame
        
        lettersLabel.text = "0"
        moneyLabel.text = "$0.00"
        
        lettersLabel.alpha = 0.0
        moneyLabel.alpha = 0.0
        lightbulbButton.alpha = 0.0
        
        lightbulbButton.setBackgroundImage(TapStyle.imageOfLightbulb(frame: CGRect(origin: CGPointZero, size: lightbulbButton.frame.size), colorLightbulb: nightMode ? UIColor.lightTextColor() : UIColor.blackColor()), forState: UIControlState.Normal)
        
        align()
        
        backgroundColor = UIColor.whiteColor()
        wrapperView.backgroundColor = UIColor.clearColor()
        lightbulbButton.backgroundColor = UIColor.clearColor()
    }
    
    func align() {
        lettersLabel.sizeToFit()
        moneyLabel.sizeToFit()
    }
    
    func getCenterLetters() -> CGPoint {
        return getCenter(lettersLabel)
    }
    
    func getCenterMoney() -> CGPoint {
        return getCenter(moneyLabel)
    }
    
    func getCenter(view: UIView) -> CGPoint {
        var newX = view.frame.origin.x
        var newY = view.frame.origin.y
        
        newX += view.frame.width / 2
        newY += view.frame.height / 2
        
        return CGPoint(x: newX, y: newY)
    }
    
    func update(data: SaveData, animated: Bool = true) {
        // Stupid hack for a stupid nib
        if self.gonnaDisplayBulb && nibView.frame == self.bounds {
            self.gonnaDisplayBulb = false
            reveal(lightbulbButton, animated: false)
        }
        else {
            nibView.frame = self.frame
        }
        
        // Night mode
        if nightMode != data.nightMode! {
            nightMode = !nightMode
            
            nibView.backgroundColor = nightMode ? UIColor.blackColor() : UIColor.whiteColor()
            lettersLabel?.textColor = nightMode ? UIColor.lightTextColor() : UIColor.blackColor()
            moneyLabel?.textColor = nightMode ? UIColor.lightTextColor() : UIColor.blackColor()
            
            lightbulbButton.setBackgroundImage(TapStyle.imageOfLightbulb(frame: CGRect(origin: CGPointZero, size: lightbulbButton.frame.size), colorLightbulb: nightMode ? UIColor.lightTextColor() : UIColor.blackColor()), forState: UIControlState.Normal)
        }
        
        if self.letters == 0 && data.letters! > 0 {
            revealLetters(animated)
        }
        if self.money == 0 && data.money! > 0 {
            revealMoney(animated)
        }
        
        self.letters = data.letters!
        self.money = data.money!
        
        let moneyText = currencyFormatter.stringFromNumber(data.money!)!
        
        lettersLabel?.text = "\(generalFormatter.stringFromNumber(self.letters)!)"
        moneyLabel?.text = "\(moneyText)"
        
        if letters > 0 && animated { pulseLetters() }
        if money > 0 && animated { pulseMoney() }
    }
    
    func revealLetters(animated: Bool) {
        reveal(lettersLabel, animated: animated)
    }
    
    func revealMoney(animated: Bool) {
        reveal(moneyLabel, animated: animated)
    }
    
    func reveal(view: UIView, animated: Bool = true) {
        UIView.animateWithDuration(animated ? 0.4 : 0.1, animations: { () -> Void in
            view.alpha = 1.0
        })
    }
    
    func pulseLetters() {
        pulse(lettersLabel)
    }
    
    func pulseMoney() {
        pulse(moneyLabel)
    }
    
    func pulse(view: UIView) {
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            view.transform = CGAffineTransformMakeScale(1.15, 1.15)
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    view.transform = CGAffineTransformIdentity
                    }, completion: nil)
        })
    }
    
    override func translatesAutoresizingMaskIntoConstraints() -> Bool {
        return false
    }
}