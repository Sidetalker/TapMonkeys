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
    var incomeTimer = NSTimer()
    var lettersPerBuffer = 0
    var individualLettersBuffer = [Int]()
    var incomePerBuffer: Float = 0
    var individualIncomeBuffer = [Float]()
    
    var saveData = SaveData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSave()
        loadMonkeys(saveData)
        loadWritings(saveData)
        loadIncome(saveData)
        
        registerForUpdates()
        updateMonkeyProduction()
        
        configureView()
        revealTab(3)
    }
    
    override func viewDidLayoutSubviews() {
        initializeHeaders()
    }
    
    func revealTab(index: Int) {
        self.viewControllers = [AnyObject]()
        
        for i in 0...index {
            self.viewControllers?.append(allViews![i])
        }
    }
    
    func updateMonkeyProduction() {
        monkeyTimer.invalidate()
        incomeTimer.invalidate()
        
        let monkeyInterval = monkeyProductionTimer()
        let incomeInterval = incomeProductionTimer()
        
        lettersPerBuffer = fullLettersPer(monkeyInterval)
        individualLettersBuffer = individualLettersPer(monkeyInterval)
        
        incomePerBuffer = fullIncomePer(incomeInterval)
        individualIncomeBuffer = individualIncomePer(incomeInterval)
        
        monkeyTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(monkeyInterval), target: self, selector: Selector("getMonkeyLetters"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(monkeyTimer, forMode: NSRunLoopCommonModes)
        
        incomeTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(incomeInterval), target: self, selector: Selector("getIncome"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(incomeTimer, forMode: NSRunLoopCommonModes)
    }
    
    func getMonkeyLetters() {
        for i in 0...count(monkeys) - 1 {
            monkeys[i].totalProduced += individualLettersBuffer[i]
            saveData.monkeyTotals![i] += individualLettersBuffer[i]
        }
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName("updateHeaders", object: self, userInfo: [
            "letters" : lettersPerBuffer,
            "animated" : false
            ])
    }
    
    func getIncome() {
        for i in 0...count(incomes) - 1 {
            incomes[i].totalProduced += individualIncomeBuffer[i]
            saveData.incomeTotals![i] += individualIncomeBuffer[i]
        }
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName("updateHeaders", object: self, userInfo: [
            "money" : incomePerBuffer,
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateIncomeProduction", name: "updateIncomeProduction", object: nil)
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
                
                tapView.dataHeader.update(saveData, animated: false)
            }
            if let monkeyView = view as? MonkeyViewController {
                if stage == 2 {
                    monkeyView.tabBarItem.badgeValue = "!"
                }
                else if stage >= 3 {
                    monkeyView.tabBarItem.badgeValue = nil
                }
                
                if monkeyView.dataHeader == nil { return }
                
                monkeyView.dataHeader.update(saveData, animated: false)
            }
            if let writingView = view as? WritingViewController {
                if stage == 6 {
                    writingView.tabBarItem.badgeValue = "!"
                }
                else if stage >= 7 {
                    writingView.tabBarItem.badgeValue = nil
                }
                
                if writingView.dataHeader == nil { return }
                
                writingView.dataHeader.update(saveData, animated: false)
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
                if let
                    writingView = view as? WritingViewController,
                    header = writingView.dataHeader
                {
                    header.update(saveData, animated: animated)
                }
                if let
                    incomeView = view as? IncomeViewController,
                    header = incomeView.dataHeader
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
        
        if saveData.stage >= 6 {
            revealTab(2)
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
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        initializeHeaders()
        
        if let tapView = viewController as? TapViewController {
            
        }
        if let monkeyView = viewController as? MonkeyViewController {
            if saveData.stage == 2 {
                monkeyView.tabBarItem.badgeValue = nil
                saveData.stage = 3
            }
        }
        if let writingView = viewController as? WritingViewController {
            if saveData.stage == 6 {
                writingView.tabBarItem.badgeValue = nil
                saveData.stage = 7
            }
        }
        
        return true
    }
}