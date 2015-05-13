//
//  TabBarController.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/8/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    var allViews: [AnyObject]?
    var defaults: NSUserDefaults!
    
    var monkeyTimer = NSTimer()
    var lettersPerBuffer = 0
    
    var saveData = SaveData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSave()
        loadMonkeys(saveData)
        updateMonkeyProduction()
        
        registerForUpdates()
        
        configureView()
    }
    
    override func viewDidLayoutSubviews() {
        initializeHeaders()
    }
    
    func reveal(index: Int) {
        self.viewControllers = [AnyObject]()
        
        for i in 0...index {
            self.viewControllers?.append(allViews![i])
        }
    }
    
    func updateMonkeyProduction() {
        monkeyTimer.invalidate()
        
        let interval = monkeyProductionTimer()
        
        lettersPerBuffer = fullLettersPer(interval)
        
        monkeyTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(interval), target: self, selector: Selector("getMonkeyLetters"), userInfo: nil, repeats: true)
    }
    
    func getMonkeyLetters() {
        let nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName("updateHeaders", object: self, userInfo: [
            "letters" : lettersPerBuffer,
            "animated" : false
            ])
    }
    
    func loadSave() {
        saveData = readDefaults()
        
        saveData = validate(saveData)
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func registerForUpdates() {
        self.delegate = self
        
        defaults = NSUserDefaults.standardUserDefaults()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSave:", name: "updateSave", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateHeaders:", name: "updateHeaders", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateMonkeyProduction", name: "updateMonkeyProduction", object: nil)
    }
    
    func initializeHeaders() {
        if allViews == nil { return }
        
        let letters = defaults.integerForKey("letters")
        let money = defaults.floatForKey("money")
        let stage = defaults.integerForKey("stage")
        
        for view in allViews! {
            if let tapView = view as? TapViewController {
                if stage >= 2 {
                    self.setTabBarVisible(true, animated: true)
                }
                
                if tapView.dataHeader == nil { return }
                
                tapView.dataHeader.update(saveData, animated: true)
            }
            else if let monkeyView = view as? MonkeyViewController {
                if stage == 2 {
                    monkeyView.tabBarItem.badgeValue = "!"
                }
                else if stage == 3 {
                    monkeyView.tabBarItem.badgeValue = nil
                }
                
                if monkeyView.dataHeader == nil { return }
                
                monkeyView.dataHeader.update(saveData, animated: true)
            }
        }
    }
    
    func updateSave(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String : AnyObject]
        
        if let encodedSave = userInfo["saveData"] as? NSData {
            var newSave = SaveData()
            encodedSave.getBytes(&newSave, length: sizeof(SaveData))
            
            saveData = newSave
            save(self, saveData)
        }
    }
    
    func updateHeaders(notification: NSNotification) {
        if allViews == nil { return }
        
        let userInfo = notification.userInfo as! [String : AnyObject]
        
        if let letters = userInfo["letters"] as? Int {
            saveData.letters! += letters
        }
        if let money = userInfo["money"] as? Float {
            saveData.money! += money
        }
        
        if let animated = userInfo["animated"] as? Bool {
            for view in allViews! {
                if let
                    tapView = view as? TapViewController,
                    header = tapView.dataHeader
                {
                    header.update(saveData, animated: animated)
                }
                if let
                    monkeyView = view as? MonkeyViewController,
                    header = monkeyView.dataHeader
                {
                    header.update(saveData, animated: animated)
                }
            }
        }
        
        save(self, saveData)
    }
    
    func configureView() {
        allViews = self.viewControllers
        
        self.setViewControllers([allViews![0], allViews![1]], animated: false)
        self.setTabBarVisible(false, animated: false)
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
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        initializeHeaders()
        
        if let tapView = viewController as? TapViewController {
            
        }
        if let monkeyView = viewController as? MonkeyViewController {
            if saveData.stage == 2 {
                monkeyView.tabBarItem.badgeValue = nil
                saveData.stage = 3
            }
        }
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