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
    var lettersPerBuffer: Float = 0
    var individualLettersBuffer = [Float]()
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
        
        let monkeyInterval: Float = 0.1
        let incomeInterval: Float = 0.1
        
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
        
        if stage >= 2 { self.setTabBarVisible(true, animated: true) }
        
        for view in allViews! {
            if let tapView = view as? TapViewController {
                if tapView.dataHeader == nil { return }
                
                tapView.dataHeader.update(saveData, animated: false)
            }
            if let monkeyView = view as? MonkeyViewController {
                if monkeyView.dataHeader == nil { return }
                
                monkeyView.dataHeader.update(saveData, animated: false)
            }
            if let writingView = view as? WritingViewController {
                if writingView.dataHeader == nil { return }
                
                writingView.dataHeader.update(saveData, animated: false)
            }
            if let incomeView = view as? IncomeViewController {
                if incomeView.dataHeader == nil { return }
                
                incomeView.dataHeader.update(saveData, animated: false)
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
        
        if let letters = userInfo["letters"] as? Float {
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
                    header = monkeyView.dataHeader,
                    table = monkeyView.monkeyTable
                {
                    header.update(saveData, animated: animated)
                    
                    if self.selectedIndex != 1 { table.tableView.reloadData() }
                }
                if let
                    writingView = view as? WritingViewController,
                    header = writingView.dataHeader,
                    table = writingView.writingTable
                {
                    header.update(saveData, animated: animated)
                    
                    if self.selectedIndex != 2 { table.tableView.reloadData() }
                }
                if let
                    incomeView = view as? IncomeViewController,
                    header = incomeView.dataHeader,
                    table = incomeView.incomeTable
                {
                    header.update(saveData, animated: animated)
                    
                    if self.selectedIndex != 3 { table.tableView.reloadData() }
                }
            }
        }
        
        save(self, saveData)
    }
    
    func configureView() {
        allViews = self.viewControllers
        
        self.setViewControllers([allViews![0], allViews![1]], animated: false)
        self.setTabBarVisible(false, animated: false)
        
        if saveData.stage <= 2 { return }
        
        if saveData.stage == 3 {
            revealTab(2)
        }
        else if saveData.stage == 4 {
            revealTab(3)
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
        
        return true
    }
}