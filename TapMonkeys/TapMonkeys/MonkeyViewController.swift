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
        self.tabBarItem.badgeValue = nil
        
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
        self.tableView.estimatedRowHeight = 232
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return count(monkeys) == 0 ? 0 : 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(monkeys)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return monkeys[indexPath.row].unlocked ? UITableViewAutomaticDimension : 232
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
                lockView.type = .Monkey
                
                lockView.customize(load(self.tabBarController))
                
                cell.contentView.addSubview(lockView)
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let
            cell = self.tableView.dequeueReusableCellWithIdentifier("cellMonkey") as? UITableViewCell,
            monkeyPic = cell.viewWithTag(1) as? UIImageView,
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
            
            monkeyPic.image = UIImage(named: curMonkey.imageName)
            
            buyButton.monkeyIndex = index
            buyButton.delegate = self
            buyButton.setNeedsDisplay()
            
            total.index = index
            total.controller = self.tabBarController as? TabBarController
            total.type = .Monkey
            
            name.text = curMonkey.name
            description.text = curMonkey.description
            owned.text = "Owned: \(curMonkey.count)"
            frequency.text = "Letters/sec: \(curMonkey.lettersPerSecondCumulative())"
            total.text = "Total Letters: \(curMonkey.totalProduced)"
            
            if let lockView = cell.contentView.viewWithTag(8) as? AnimatedLockView {
                lockView.index = index
                lockView.type = .Monkey
                lockView.customize(load(self.tabBarController))
                
                if curMonkey.unlocked { lockView.removeFromSuperview() }
            }
            
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
        
        for cost in monkeys[index].unlockCost {
            if saveData.incomeCounts![Int(cost.0)] < Int(cost.1) { return }
        }
        
        for cost in monkeys[index].unlockCost {
            saveData.incomeCounts![Int(cost.0)] -= Int(cost.1)
            incomes[Int(cost.0)].count -= Int(cost.1)
        }
        
        view.unlock()
        
        saveData.monkeyUnlocks![index] = true
        monkeys[index].unlocked = true
        
        if index + 1 <= count(monkeys) - 1 {
            var paths = [NSIndexPath]()
            
            self.tableView.beginUpdates()
            
            for i in index + 1...count(monkeys) - 1 {
                paths.append(NSIndexPath(forRow: i, inSection: 0))
            }
            
            self.tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.None)
            
            self.tableView.endUpdates()
        }
        
        save(self.tabBarController, saveData)
    }
    
    // REFACTOR you wrote this all stupid cause you wanted to move on
    func buyTapped(monkeyIndex: Int) {
        var saveData = load(self.tabBarController)
        var monkey = monkeys[monkeyIndex]
        
        if monkey.canPurchase(1, data: saveData) {
            var price = monkey.getPrice(1).0 * -1
            
            saveData = monkey.purchase(1, data: saveData)!
            
            monkeys[monkeyIndex] = monkey
            
            save(self.tabBarController, saveData)
            
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName("updateHeaders", object: self, userInfo: [
                "money" : price,
                "animated" : false
                ])
            nc.postNotificationName("updateMonkeyProduction", object: self, userInfo: nil)
            
            delay(0.2, {
                self.tableView.reloadData()
                
//                self.tableView.beginUpdates()
//                
//                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: monkeyIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
//                
//                self.tableView.endUpdates()
            })
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
        
        TapStyle.drawBuy(frame: rect, buyText: text)
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