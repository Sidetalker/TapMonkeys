//
//  MonkeyViewController.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/9/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

class MonkeyViewController: UIViewController {
    @IBOutlet weak var dataHeader: DataHeader!
    
    var monkeyTable: MonkeyTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueMonkeyTable" {
            monkeyTable = segue.destinationViewController as? MonkeyTableViewController
        }
    }
}

class MonkeyTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, AnimatedLockDelegate, MonkeyBuyButtonDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 250
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return count(monkeys) == 0 ? 0 : 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(monkeys)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        let curMonkey = monkeys[index]
        
        if !curMonkey.unlocked {
            if let lockView = cell.contentView.viewWithTag(8) as? AnimatedLockView {
                // We're good to go I guess
            }
            else {
                let lockView = AnimatedLockView(frame: cell.contentView.frame)
                lockView.tag = 8
                lockView.index = indexPath.row
                lockView.delegate = self
                lockView.type = AnimatedLockViewType.Monkey
                
                if index == 0 {
                    cell.contentView.addSubview(lockView)
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let
            cell = self.tableView.dequeueReusableCellWithIdentifier("cellMonkey") as? UITableViewCell,
            monkeyPic = cell.viewWithTag(1) as? MonkeyPicture,
            name = cell.viewWithTag(2) as? UILabel,
            owned = cell.viewWithTag(3) as? UILabel,
            frequency = cell.viewWithTag(4) as? UILabel,
            total = cell.viewWithTag(5) as? AutoUpdateLabel,
            buyButton = cell.viewWithTag(6) as? MonkeyBuyButton,
            description = cell.viewWithTag(7) as? UILabel
        {
            let index = indexPath.row
            let curMonkey = monkeys[index]
            let curPrice = curMonkey.getPrice(1).0
            
            monkeyPic.monkeyIndex = index
            monkeyPic.setNeedsDisplay()
            
            buyButton.monkeyIndex = index
            buyButton.delegate = self
            buyButton.setNeedsDisplay()
            
            total.index = index
            total.controller = self.tabBarController as? TabBarController
            
            name.text = curMonkey.name
            description.text = curMonkey.description
            owned.text = "Owned: \(curMonkey.count)"
            frequency.text = "Letters/sec: \(curMonkey.lettersPerSecondCumulative())"
            total.text = "Total Letters: \(curMonkey.totalProduced)"
            
            return cell
        }
        else {
            println("Unable to load monkey cell / subviews!")
        }
        
        return UITableViewCell()
    }
    
    func tappedLock(view: AnimatedLockView) {
        var saveData = load(self.tabBarController)
        let index = view.index
        
        if index == 0 && saveData.stage == 3 || saveData.stage == 4 {
            view.unlock()
            
            saveData.stage = 4
            saveData.monkeyUnlocks![index] = true
            monkeys[index].unlocked = true
            
            save(self.tabBarController, saveData)
        }
    }
    
    // REFACTOR you wrote this all stupid cause you wanted to move on
    func buyTapped(monkeyIndex: Int) {
        var saveData = load(self.tabBarController)
        var monkey = monkeys[monkeyIndex]
        
        if monkeyIndex == 0 && saveData.stage == 4 {
            if monkey.canPurchase(1, data: saveData) {
                var price = monkey.getPrice(1).0 * -1
                
                saveData = monkey.purchase(1, data: saveData)!
                
                monkeys[monkeyIndex] = monkey
                
                saveData.monkeyCounts![monkeyIndex] = monkey.count
                saveData.monkeyTotals![monkeyIndex] = monkey.lettersTotal()
                saveData.monkeyLastMod![monkeyIndex] = monkey.previousMod
                saveData.monkeyLastCost![monkeyIndex] = monkey.previousCost
                
                saveData.stage = 5
                
                save(self.tabBarController, saveData)
                
                delay(0.2, {
                    self.tableView.reloadData()
                    
                    let nc = NSNotificationCenter.defaultCenter()
                    nc.postNotificationName("updateHeaders", object: self, userInfo: [
                        "letters" : price,
                        "animated" : false
                        ])
                    nc.postNotificationName("updateMonkeyProduction", object: self, userInfo: nil)
                })
            }
        }
        else {
            if monkey.canPurchase(1, data: saveData) {
                var price = monkey.getPrice(1).0 * -1
                
                saveData = monkey.purchase(1, data: saveData)!
                
                monkeys[monkeyIndex] = monkey
                
                saveData.monkeyCounts![monkeyIndex] = monkey.count
                saveData.monkeyTotals![monkeyIndex] = monkey.lettersTotal()
                saveData.monkeyLastMod![monkeyIndex] = monkey.previousMod
                saveData.monkeyLastCost![monkeyIndex] = monkey.previousCost
                
                save(self.tabBarController, saveData)
                
                delay(0.2, {
                    self.tableView.reloadData()
                    
                    let nc = NSNotificationCenter.defaultCenter()
                    nc.postNotificationName("updateHeaders", object: self, userInfo: [
                        "money" : price,
                        "animated" : false
                        ])
                    nc.postNotificationName("updateMonkeyProduction", object: self, userInfo: nil)
                })
            }
        }
    }
}

class MonkeyPicture: UIView {
    var monkeyIndex = 0
    var strokeWidth: CGFloat = 0.5
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    init(frame: CGRect, strokeWidth: CGFloat) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.strokeWidth = strokeWidth
        
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        if monkeyIndex == 0 {
            TapStyle.drawFingerMonkey()
        }
        else if monkeyIndex == 1 {
            TapStyle.drawGoofkey()
        }
        else if monkeyIndex == 2 {
            TapStyle.drawDigitDestroyer()
        }
        else if monkeyIndex == 3 {
            TapStyle.drawSeaMonkey()
        }
        else if monkeyIndex == 4 {
            TapStyle.drawJabbaTheMonkey()
        }
    }
}

protocol MonkeyBuyButtonDelegate {
    func buyTapped(monkeyIndex: Int)
}

class MonkeyBuyButton: UIView {
    // 0 is 1 only, 1 is 1 | 10, 2 is 1 | 10 | 100
    // Like, maybe
    var state = 0
    var monkeyIndex = -1
    
    var delegate: MonkeyBuyButtonDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
        
        let tap = UILongPressGestureRecognizer(target: self, action: "tappedMe:")
        tap.minimumPressDuration = 0.0
        
        self.addGestureRecognizer(tap)
    }
    
    override func drawRect(rect: CGRect) {
        let price = monkeys[monkeyIndex].getPrice(1).0
        
        let text = NSString(format: "$%.2f", price) as String
        
        TapStyle.drawBuy(frame: rect, monkeyBuyText: text)
    }
    
    
    func tappedMe(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            UIView.animateWithDuration(0.15, animations: {
                self.transform = CGAffineTransformMakeScale(0.91, 0.91)
            })
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            self.delegate?.buyTapped(self.monkeyIndex)
            
            UIView.animateWithDuration(0.35, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                self.transform = CGAffineTransformIdentity
                }, completion: { (Bool) -> Void in
                    
            })
        }
    }
}