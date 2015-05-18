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

class DrawnPicture: UIView {
    var index = 0
    var type: ObjectType = .Monkey
    var unknown = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    init(frame: CGRect, strokeWidth: CGFloat) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        if unknown {
            TapStyle.drawUnknownUnlock()
            return
        }
        
        if type == .Income {
            if index == 0 {
                TapStyle.drawBaby()
            }
            else if index == 1 {
                TapStyle.drawKindergartner()
            }
            else if index == 2 {
                TapStyle.drawFourthGrader()
            }
            else if index == 3 {
                TapStyle.drawElementaryTeacher()
            }
            else if index == 4 {
                TapStyle.drawElementarySchool()
            }
        }
        else if type == .Monkey {
            if index == 0 {
                TapStyle.drawFingerMonkey()
            }
            else if index == 1 {
                TapStyle.drawGoofkey()
            }
            else if index == 2 {
                TapStyle.drawDigitDestroyer()
            }
            else if index == 3 {
                TapStyle.drawSeaMonkey()
            }
            else if index == 4 {
                TapStyle.drawJabbaTheMonkey()
            }
        }
        else if type == .Writing {
            if index == 0 {
                TapStyle.drawWords()
            }
            else if index == 1 {
                TapStyle.drawFragmentedSentence()
            }
            else if index == 2 {
                TapStyle.drawSentence()
            }
            else if index == 3 {
                TapStyle.drawTextMessage()
            }
            else if index == 4 {
                TapStyle.drawTweet()
            }
        }
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
            self.text = "Total Letters: \(Int(saveData.monkeyTotals![index]))"
        }
        else if type == .Income {
            let amount = NSString(format: "%.2f", saveData.incomeTotals![index]) as String
            
            self.text = "Total: $\(amount)"
        }
    }
}

protocol AnimatedLockDelegate {
    func tappedLock(view: AnimatedLockView)
}

class AnimatedLockView: UIView {
    @IBOutlet var nibView: UIView!
    @IBOutlet weak var lockImage: UIImageView!
    @IBOutlet weak var requirementsText: UILabel!
    @IBOutlet weak var staticText: UILabel!
    @IBOutlet weak var pic: DrawnPicture!
    
    var locked = true
    var type: ObjectType = .Monkey
    var index = -1
    var animator: UIDynamicAnimator?
    var delegate: AnimatedLockDelegate?
    var transitionView: UIView?
    
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
        
        var animationImages = [UIImage]()
        
        for i in 1...12 {
            let imageName = "animatedLock" + (NSString(format: "%02d", i) as String)
            
            if let image = UIImage(named: imageName) {
                animationImages.append(image)
            }
            else {
                println("Error: Unable to load all images for animated lock sequence")
                break
            }
        }
        
        lockImage.animationImages = animationImages
        lockImage.animationDuration = 0.35
        lockImage.animationRepeatCount = 1
        
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("lockTap:"))
        
        self.addGestureRecognizer(singleTap)
    }
    
    func customize(saveData: SaveData) {
        if self.superview != nil {
            self.frame = self.superview!.frame
        }
        
        staticText.text = "Unlock With"
        
        if type == .Monkey {
            if index > 1 {
                if !saveData.monkeyUnlocks![index - 1] && !saveData.monkeyUnlocks![index - 2] {
                    requirementsText.text = "?????"
                    
                    pic.unknown = true
                    pic.setNeedsDisplay()
                    
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
        }
        else if type == .Writing {
            if index > 1 {
                if !saveData.writingUnlocked![index - 1] && !saveData.writingUnlocked![index - 2] {
                    requirementsText.text = "?????"
                    
                    pic.unknown = true
                    pic.setNeedsDisplay()
                    
                    return
                }
            }
            
            requirementsText.text = "\(writings[index].unlockCost) Letters"
            
            if writings[index].unlockCost == 0 {
                staticText.text = "Unlock For"
                requirementsText.text = "FREE"
            }
        }
        else if type == .Income {
            if index > 1 {
                if !saveData.incomeUnlocks![index - 1] && !saveData.incomeUnlocks![index - 2] {
                    requirementsText.text = "?????"
                    
                    pic.unknown = true
                    pic.setNeedsDisplay()
                    
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
        }
        
        pic.unknown = false
        pic.type = type
        pic.index = index
        pic.setNeedsDisplay()
    }
    
    func lockTap(sender: UITapGestureRecognizer) {
        delegate?.tappedLock(self)
    }
    
    func unlock() {
        lockImage.image = UIImage(named: "animatedLock12")
        
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
            self.transitionView!.alpha = 0.0
            self.requirementsText.alpha = 0.0
            self.staticText.alpha = 0.0
            }, completion: { (Bool) -> Void in
                
        })
        
        UIView.animateWithDuration(0.51, delay: 0.39, options: nil, animations: { () -> Void in
            self.lockImage.alpha = 0.0
            }, completion: { (Bool) -> Void in
                self.removeFromSuperview()
        })
    }
}

//@IBDesignable class DataHeader: UIView {
class DataHeader: UIView {
    @IBOutlet var nibView: UIView!
    
    @IBOutlet weak var lettersLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    
    var letters: Float = 0
    var money: Float = 0
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    func configure() {
        NSBundle.mainBundle().loadNibNamed("DataHeader", owner: self, options: nil)
        
        self.addSubview(nibView)
        self.frame = nibView.frame
        
        lettersLabel.text = "0"
        moneyLabel.text = "$0.00"
        
        lettersLabel.alpha = 0.0
        moneyLabel.alpha = 0.0
        
        align()
        
        self.backgroundColor = UIColor.whiteColor()
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
    
    func getCenter(view: UIView) ->CGPoint {
        var newX = view.frame.origin.x
        var newY = view.frame.origin.y
        
        newX += view.frame.width / 2
        newY += view.frame.height / 2
        
        return CGPoint(x: newX, y: newY)
    }
    
    func update(data: SaveData, animated: Bool = true) {
        if self.letters == 0 && data.letters! > 0 {
            revealLetters(animated)
        }
        if self.money == 0 && data.money! > 0 {
            revealMoney(animated)
        }
        
        self.letters = data.letters!
        self.money = data.money!
        
        let moneyText = NSString(format: "%.2f", data.money!) as String
        
        lettersLabel?.text = "\(Int(self.letters))"
        moneyLabel?.text = "$\(moneyText)"
        
        align()
        
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
}