//
//  TabBarController.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/8/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

struct SaveData {
    var letters: Int
    var money: Float
    var letterCounts: [Int]
}

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    var allHeaders = [DataHeader?]()
    
    var allViews: [AnyObject]?
    var defaults: NSUserDefaults?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
        defaults = NSUserDefaults.standardUserDefaults()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateHeaders:", name: "updateHeaders", object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        prepareViews()
    }
    
    func updateHeaders(notification: NSNotification) {
        if allViews == nil { return }
        
        for view in allViews! {
            let userInfo = notification.userInfo as! [String : Float]
            var updateLetters = 0
            var updateMoney: Float = 0
            
            if let letters = userInfo["letters"] {
                updateLetters = Int(letters)
            }
            if let money = userInfo["money"] {
                updateMoney = money
            }
            
            if let tapView = view as? TapViewController {
                tapView.dataHeader.update(letters: updateLetters, money: updateMoney)
            }
        }
    }
    
    func configureView() {
        allViews = self.viewControllers
        
        self.setViewControllers([allViews![0], allViews![1]], animated: false)
        self.setTabBarVisible(false, animated: false)
    }
    
    func prepareViews() {
        for view in allViews! {
            var found = false
            
            if let curView = view as? UIView {
                for subview in curView.subviews {
                    if let header = subview as? DataHeader {
                        allHeaders.append(header)
                        found = true
                        
                        break
                    }
                }
            }
            
            if !found {
                allHeaders.append(nil)
            }
        }
    }
    
    func setTabBarVisible(visible: Bool, animated: Bool) {
        if (tabBarIsVisible() == visible) { return }
        
        let screenRect = UIScreen.mainScreen().bounds
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(animated ? 0.6 : 0.0)
        
        var height = screenRect.height
        
        if (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)) {
            height = screenRect.size.width
        }
        
        if visible { height -= self.tabBar.frame.height }
        
        self.tabBar.frame = CGRect(x: self.tabBar.frame.origin.x, y: height, width: self.tabBar.frame.width, height: self.tabBar.frame.height)
        
        UIView.commitAnimations()
    }
    
    func tabBarIsVisible() -> Bool {
        return self.tabBar.frame.origin.y != CGRectGetMaxY(self.view.frame)
    }
    
    func tabBarHeight() -> CGFloat {
        return self.tabBar.bounds.size.height
    }
}

class DataHeader: UIView {
    var lettersLabel: UILabel!
    var moneyLabel: UILabel!
    
    var letters = 0
    var money: Float = 0
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    func configure() {
        lettersLabel = UILabel(frame: CGRect(x: 22, y: 0, width: self.frame.width, height: 40))
        moneyLabel = UILabel(frame: CGRect(x: 8, y: 29, width: self.frame.width, height: 40))
        
        lettersLabel.font = UIFont(name: "Noteworthy-Light", size: 27)
        moneyLabel.font = UIFont(name: "Noteworthy-Light", size: 27)
        
        lettersLabel.text = "0"
        moneyLabel.text = "$0.00"
        
        lettersLabel.alpha = 0.0
        moneyLabel.alpha = 0.0
        
        lettersLabel.sizeToFit()
        moneyLabel.sizeToFit()
        
        self.addSubview(lettersLabel)
        self.addSubview(moneyLabel)
        
        self.backgroundColor = UIColor.clearColor()
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
    
    func update(letters: Int = 0, money: Float = 0) {
        if self.letters == 0 && letters > 0 {
            revealLetters()
        }
        if self.money == 0 && money > 0 {
            revealMoney()
        }
        
        self.letters += letters
        self.money += money
        
        let moneyText = NSString(format: "%.2f", money) as String
        
        lettersLabel?.text = "\(self.letters)"
        moneyLabel?.text = "$\(moneyText)"
        
        lettersLabel?.sizeToFit()
        moneyLabel?.sizeToFit()
        
        if letters > 0 { pulseLetters() }
        if money > 0 { pulseMoney() }
    }
    
    func revealLetters() {
        reveal(lettersLabel)
    }
    
    func revealMoney() {
        reveal(moneyLabel)
    }
    
    func reveal(view: UIView) {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
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