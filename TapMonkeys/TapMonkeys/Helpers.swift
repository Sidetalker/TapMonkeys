//
//  Helpers.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/8/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import QuartzCore

func delay(delay: Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func randomFloatBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
    return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
}

func randomIntBetweenNumbers(firstNum: Int, secondNum: Int) -> Int {
    let first = CGFloat(firstNum)
    let second = CGFloat(secondNum)
    let random = randomFloatBetweenNumbers(first, second)
    
    return Int(random)
}

protocol PopLabelDelegate {
    func finishedPopping(customEnd: Bool)
}

class PopLabel: UIView {
    var delegate: PopLabelDelegate?
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
    
    override func drawRect(rect: CGRect) {
        TapStyle.drawMainLetter(character: alphabet[index])
    }
    
    func setCharIndex(charIndex: Int) {
        index = charIndex
        
        setNeedsDisplay()
    }
    
    func setChar(character: String) {
        setCharIndex(find(alphabet, character)!)
    }
    
    var animator: UIDynamicAnimator?
    
    func pop(remove: Bool = true, customEnd: Bool = false, customPoint: CGPoint = CGPointZero) {
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
        
        delay(0.8, {
            self.animator?.removeAllBehaviors()
            
            // Scale and fade
            UIView.animateWithDuration(fadeTime, delay: 0.0, options: nil, animations: {
                self.transform = CGAffineTransformMakeScale(curScale, curScale)
                self.frame = CGRect(origin: customEnd ? customPoint : CGPoint(x: 5, y: self.superview!.frame.height - 20), size: CGSize(width: 28, height: 28))
                self.alpha = customEnd ? 1.0 : 0.0
                }, completion: { (Bool) -> Void in
                    self.delegate?.finishedPopping(customEnd)
                    if remove { self.removeFromSuperview() }
            })
        })
        
    }
}