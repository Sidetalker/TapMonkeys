//
//  IncomeViewController.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/15/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

class IncomeViewController: UIViewController {
    @IBOutlet weak var dataHeader: DataHeader!
    
    var incomeTable: IncomeTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarItem.badgeValue = nil
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.postNotificationName("updateHeaders", object: self, userInfo: [
            "letters" : 0,
            "animated" : true
            ])
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueIncomeTable" {
            incomeTable = segue.destinationViewController as? IncomeTableViewController
        }
    }
}

class IncomeTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, AnimatedLockDelegate, IncomeBuyButtonDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 232
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return count(incomes) == 0 ? 0 : 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(incomes)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return incomes[indexPath.row].unlocked ? UITableViewAutomaticDimension : 232
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        let curIncome = incomes[index]
        
        if !curIncome.unlocked {
            if let lockView = cell.contentView.viewWithTag(8) as? AnimatedLockView {
                // That betch is hooked up, no worriez
            }
            else {
                let lockView = AnimatedLockView(frame: cell.contentView.frame)
                lockView.tag = 8
                lockView.index = indexPath.row
                lockView.delegate = self
                lockView.type = AnimatedLockViewType.Income
                
                lockView.customize(load(self.tabBarController))
                
                cell.contentView.addSubview(lockView)
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let
            cell = tableView.dequeueReusableCellWithIdentifier("cellIncome") as? UITableViewCell,
            pic = cell.viewWithTag(1) as? IncomePicture,
            title = cell.viewWithTag(2) as? UILabel,
            owned = cell.viewWithTag(3) as? UILabel,
            moneyPerSec = cell.viewWithTag(4) as? UILabel,
            totalMoney = cell.viewWithTag(5) as? AutoUpdateLabel,
            button = cell.viewWithTag(6) as? IncomeBuyButton,
            description = cell.viewWithTag(7) as? UILabel
        {
            let index = indexPath.row
            let moneyText = NSString(format: "%.2f", incomes[index].moneyPerSecond()) as String
            
            pic.incomeIndex = index
            title.text = incomes[index].name
            description.text = incomes[index].description
            owned.text = "Owned: \(incomes[index].count)"
            moneyPerSec.text = "$/sec: $\(moneyText)"
            totalMoney.text = "Total: $\(incomes[index].totalProduced)"
            button.incomeIndex = index
            
            button.delegate = self
            
            totalMoney.index = index
            totalMoney.controller = self.tabBarController as? TabBarController
            totalMoney.type = .Income
            
            pic.setNeedsDisplay()
            button.setNeedsDisplay()
            
            if let lockView = cell.contentView.viewWithTag(8) as? AnimatedLockView {
                lockView.index = index
                lockView.type = .Income
                lockView.customize(load(self.tabBarController))
                
                if incomes[index].unlocked { lockView.removeFromSuperview() }
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func buyTapped(incomeIndex: Int) {
        var saveData = load(self.tabBarController)
        var income = incomes[incomeIndex]
        
        var price = Int(income.getPrice(1).0)
        
        if let newSave = income.purchase(1, data: saveData) {
            save(self.tabBarController, newSave)
            
            incomes[incomeIndex] = income
            
            delay(0.2, {
                self.tableView.reloadData()
                
                let nc = NSNotificationCenter.defaultCenter()
                nc.postNotificationName("updateHeaders", object: self, userInfo: [
                    "letters" : -price,
                    "animated" : false
                    ])
                nc.postNotificationName("updateMonkeyProduction", object: self, userInfo: nil)
            })
        }
    }
    
    func tappedLock(view: AnimatedLockView) {
        var saveData = load(self.tabBarController)
        let index = view.index
        
        for cost in incomes[index].unlockCost {
            if saveData.writingCount![Int(cost.0)] < Int(cost.1) { return }
        }
        
        for cost in incomes[index].unlockCost {
            saveData.writingCount![Int(cost.0)] -= Int(cost.1)
            writings[Int(cost.0)].count -= Int(cost.1)
        }
        
        view.unlock()
        
        saveData.incomeUnlocks![index] = true
        incomes[index].unlocked = true
        
        if index + 1 <= count(incomes) - 1 {
            var paths = [NSIndexPath]()
            
            self.tableView.beginUpdates()
            
            for i in index + 1...count(incomes) - 1 {
                paths.append(NSIndexPath(forRow: i, inSection: 0))
            }
            
            self.tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.None)
            
            self.tableView.endUpdates()
        }
        
        save(self.tabBarController, saveData)
    }
}

class IncomePicture: UIView {
    var incomeIndex = 0
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    init(frame: CGRect, strokeWidth: CGFloat) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        if incomeIndex == 0 {
            TapStyle.drawBaby()
        }
        else if incomeIndex == 1 {
            TapStyle.drawKindergartner()
        }
        else if incomeIndex == 2 {
            TapStyle.drawFourthGrader()
        }
        else if incomeIndex == 3 {
            TapStyle.drawElementaryTeacher()
        }
        else if incomeIndex == 4 {
            TapStyle.drawElementarySchool()
        }
    }
}

protocol IncomeBuyButtonDelegate {
    func buyTapped(incomeIndex: Int)
}

class IncomeBuyButton: UIView {
    // 0 is 1 only, 1 is 1 | 10, 2 is 1 | 10 | 100
    // Like, maybe
    var state = 0
    var incomeIndex = -1
    
    var delegate: IncomeBuyButtonDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
        
        let tap = UILongPressGestureRecognizer(target: self, action: "tappedMe:")
        tap.minimumPressDuration = 0.0
        
        self.addGestureRecognizer(tap)
    }
    
    override func drawRect(rect: CGRect) {
        if state == 0 {
            var text = incomes[incomeIndex].getPurchaseString(1)
            
            TapStyle.drawBuy(frame: rect, monkeyBuyText: text)
        }
    }
    
    
    func tappedMe(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            UIView.animateWithDuration(0.15, animations: {
                self.transform = CGAffineTransformMakeScale(0.91, 0.91)
            })
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            self.delegate?.buyTapped(self.incomeIndex)
            
            UIView.animateWithDuration(0.35, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                self.transform = CGAffineTransformIdentity
                }, completion: { (Bool) -> Void in
                    
            })
        }
    }
}