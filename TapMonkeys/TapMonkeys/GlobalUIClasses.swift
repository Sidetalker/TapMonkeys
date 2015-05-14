//
//  GlobalUIClasses.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/13/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

enum AnimatedLockViewType {
    case Monkey
    case Writing
}

protocol AnimatedLockDelegate {
    func tappedLock(view: AnimatedLockView)
}

class AnimatedLockView: UIView {
    @IBOutlet var nibView: UIView!
    @IBOutlet weak var lockImage: UIImageView!
    @IBOutlet weak var requirementsText: UILabel!
    @IBOutlet weak var staticText: UILabel!
    
    var locked = true
    var type = AnimatedLockViewType.Monkey
    var index = -1
    var blurView: UIVisualEffectView!
    var animator: UIDynamicAnimator?
    var delegate: AnimatedLockDelegate?
    
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
        
        let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
        blurView = UIVisualEffectView(effect: blur)
        
        blurView.frame = self.frame
        blurView.tag = 1
        
        self.backgroundColor = UIColor.clearColor()
        
        self.nibView.addSubview(blurView)
        self.nibView.sendSubviewToBack(blurView)
        
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
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: nil, animations: { () -> Void in
            self.requirementsText.alpha = 0.0
            self.staticText.alpha = 0.0
            }, completion: { (Bool) -> Void in
                
        })
        
        UIView.animateWithDuration(1.1, delay: 0.2, options: nil, animations: { () -> Void in
            self.blurView?.alpha = 0.0
            }, completion: { (Bool) -> Void in
                self.removeFromSuperview()
        })
        
        UIView.animateWithDuration(0.51, delay: 0.39, options: nil, animations: { () -> Void in
            self.lockImage.alpha = 0.0
            }, completion: { (Bool) -> Void in
                
        })
    }
}

//@IBDesignable class DataHeader: UIView {
class DataHeader: UIView {
    @IBOutlet var nibView: UIView!
    
    @IBOutlet weak var lettersLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    
    var letters = 0
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
        
        self.backgroundColor = UIColor.clearColor()
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
        
        lettersLabel?.text = "\(self.letters)"
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
            view.transform = CGAffineTransformMakeScale(1.35, 1.35)
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    view.transform = CGAffineTransformIdentity
                    }, completion: nil)
        })
    }
}