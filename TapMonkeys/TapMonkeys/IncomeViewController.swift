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
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        let curWriting = writings[index]
        
        if !curWriting.unlocked {
            if let lockView = cell.contentView.viewWithTag(8) as? AnimatedLockView {
                // That betch is hooked up, no worriez
            }
            else {
                let lockView = AnimatedLockView(frame: cell.contentView.frame)
                lockView.tag = 8
                lockView.index = indexPath.row
                lockView.delegate = self
                lockView.type = AnimatedLockViewType.Writing
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
            totalMoney = cell.viewWithTag(5) as? UILabel,
            button = cell.viewWithTag(6) as? IncomeBuyButton,
            description = cell.viewWithTag(7) as? UILabel
        {
            let index = indexPath.row
//            let moneyText = NSString(format: "%.2f", writings[index].getValue()) as String
            
            pic.incomeIndex = index
            title.text = writings[index].name
            description.text = writings[index].description
//            owned.text = "Owned: \(incomes[index].count)"
//            value.text = "$/sec: $\(moneyText)"
//            level.text = "Total: \(writings[index].level)"
            button.incomeIndex = index
            
            button.delegate = self
            
            pic.setNeedsDisplay()
            button.setNeedsDisplay()
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func buyTapped(writingIndex: Int) {
        var saveData = load(self.tabBarController)
        var writing = writings[writingIndex]
        
        var price = writing.getPrice(1).2
        
        if let newSave = writing.purchase(1, data: saveData) {
            save(self.tabBarController, newSave)
            
            writings[writingIndex] = writing
            
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
        return
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
//            let priceLow = writings[writingIndex].getPrice(1).0
//            let priceHigh = writings[writingIndex].getPrice(1).1
            var text = "Placeholder"
            
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