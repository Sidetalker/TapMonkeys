//
//  WritingViewController.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/13/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

class WritingViewController: UIViewController {
    @IBOutlet weak var dataHeader: DataHeader!
    
    var writingTable: WritingTableViewController?
    var nightMode = false
    
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
        if segue.identifier == "segueWritingTable" {
            writingTable = segue.destinationViewController as? WritingTableViewController
        }
    }
    
    func toggleNightMode(nightMode: Bool) {
        self.nightMode = nightMode
        self.view.backgroundColor = self.nightMode ? UIColor.lightTextColor() : UIColor.blackColor()
        self.tabBarController?.tabBar.setNeedsDisplay()
        
        writingTable?.toggleNightMode(nightMode)
    }
}

class WritingTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, AnimatedLockDelegate, WritingBuyButtonDelegate {
    
    var nightMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 232
    }
    
    func toggleNightMode(nightMode: Bool) {
        self.nightMode = nightMode
        self.view.backgroundColor = nightMode ? UIColor.blackColor() : UIColor.whiteColor()
        self.tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return count(writings) == 0 ? 0 : 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(writings)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let saveData = load(self.tabBarController)
        
        if !saveData.writingCollapsed![indexPath.row] {
            return writings[indexPath.row].unlocked ? UITableViewAutomaticDimension : 232
        }
        else {
            return writings[indexPath.row].unlocked ? 60 : 232
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let saveData = load(self.tabBarController)
        let index = indexPath.row
        
        if saveData.writingCollapsed![index] { return }
        
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
                lockView.type = .Writing
                
                lockView.customize(load(self.tabBarController))
                
                cell.contentView.addSubview(lockView)
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let saveData = load(self.tabBarController)
        let index = indexPath.row
        let curWriting = writings[index]
        
        if !saveData.writingCollapsed![index] {
            if let
                cell = tableView.dequeueReusableCellWithIdentifier("cellWriting") as? UITableViewCell,
                pic = cell.viewWithTag(1) as? UIImageView,
                title = cell.viewWithTag(2) as? UILabel,
                owned = cell.viewWithTag(3) as? UILabel,
                value = cell.viewWithTag(4) as? UILabel,
                level = cell.viewWithTag(5) as? UILabel,
                button = cell.viewWithTag(6) as? WritingBuyButton,
                description = cell.viewWithTag(7) as? UILabel
            {
                let index = indexPath.row
                let moneyText = currencyFormatter.stringFromNumber(curWriting.getValue())!
                
                pic.image = UIImage(named: writings[index].imageName)
                pic.alpha = nightMode ? 0.5 : 1.0
                
                title.text = curWriting.name
                description.text = curWriting.description
                owned.text = "Owned: \(generalFormatter.stringFromNumber(curWriting.count)!)"
                value.text = "Value: \(moneyText)"
                level.text = "Level: \(generalFormatter.stringFromNumber(curWriting.level)!)"
                button.writingIndex = index
                
                title.textColor = nightMode ? UIColor.lightTextColor() : UIColor.blackColor()
                description.textColor = nightMode ? UIColor.lightTextColor() : UIColor.blackColor()
                owned.textColor = nightMode ? UIColor.lightTextColor() : UIColor.blackColor()
                value.textColor = nightMode ? UIColor.lightTextColor() : UIColor.blackColor()
                level.textColor = nightMode ? UIColor.lightTextColor() : UIColor.blackColor()
                
                button.delegate = self
                button.nightMode = nightMode
                button.setNeedsDisplay()
                
                cell.contentView.backgroundColor = nightMode ? UIColor.blackColor() : UIColor.whiteColor()
                
                if let lockView = cell.contentView.viewWithTag(8) as? AnimatedLockView {
                    lockView.index = index
                    lockView.frame = cell.contentView.frame
                    lockView.type = .Writing
                    lockView.customize(load(self.tabBarController))
                    
                    if curWriting.unlocked { lockView.removeFromSuperview() }
                }
                else {
                    if pic.gestureRecognizers == nil {
                        let briefHold = UILongPressGestureRecognizer(target: self, action: "heldPic:")
                        
                        pic.addGestureRecognizer(briefHold)
                    }
                }
                
                pic.setNeedsDisplay()
                button.setNeedsDisplay()
                
                return cell
            }
        }
        else {
            if let
                cell = self.tableView.dequeueReusableCellWithIdentifier("cellWritingMini") as? UITableViewCell,
                pic = cell.viewWithTag(1) as? UIImageView,
                name = cell.viewWithTag(2) as? UILabel
            {
                pic.image = UIImage(named: curWriting.imageName)
                pic.alpha = nightMode ? 0.5 : 1.0
                
                name.text = curWriting.name
                name.textColor = nightMode ? UIColor.lightTextColor() : UIColor.blackColor()
                
                cell.contentView.backgroundColor = nightMode ? UIColor.blackColor() : UIColor.whiteColor()
                
                if pic.gestureRecognizers == nil {
                    let briefHold = UILongPressGestureRecognizer(target: self, action: "heldPic:")
                    
                    pic.addGestureRecognizer(briefHold)
                }
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func heldPic(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.Began { return }
        
        var saveData = load(self.tabBarController)
        let location = sender.locationInView(self.tableView)
        let indexPath = tableView.indexPathForRowAtPoint(location)
        let index = indexPath!.row
        
        self.tableView.beginUpdates()
        
        saveData.writingCollapsed![index] = !saveData.writingCollapsed![index]
        save(self.tabBarController, saveData)
        
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        
        self.tableView.endUpdates()
    }
    
    func buyTapped(writingIndex: Int) {
        var saveData = load(self.tabBarController)
        var writing = writings[writingIndex]
        
        var price = writing.getPrice(1).2
        
        if let newSave = writing.purchase(1, data: saveData) {
            save(self.tabBarController, newSave)
            
            writings[writingIndex] = writing
            
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName("updateHeaders", object: self, userInfo: [
                "letters" : -price,
                "animated" : false
                ])
            
            delay(0.2, {
                self.tableView.reloadData()
                
//                self.tableView.beginUpdates()
//                
//                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: writingIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
//                
//                self.tableView.endUpdates()
            })
        }
    }
    
    func tappedLock(view: AnimatedLockView) {
        var saveData = load(self.tabBarController)
        let index = view.index
        
        if Int(saveData.letters!) < writings[index].unlockCost { return }
        
        saveData.letters! -= Float(writings[index].unlockCost)
        
        view.unlock()
        
        saveData.writingUnlocked![index] = true
        writings[index].unlocked = true
        
        if index + 1 <= count(writings) - 1 {
            var paths = [NSIndexPath]()
            
            self.tableView.beginUpdates()
            
            for i in index + 1...count(writings) - 1 {
                paths.append(NSIndexPath(forRow: i, inSection: 0))
            }
            
            self.tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.None)
            
            self.tableView.endUpdates()
        }
        
        save(self.tabBarController, saveData)
    }
}

protocol WritingBuyButtonDelegate {
    func buyTapped(writingIndex: Int)
}

class WritingBuyButton: UIView {
    // 0 is 1 only, 1 is 1 | 10, 2 is 1 | 10 | 100
    // Like, maybe
    var state = 0
    var writingIndex = -1
    var nightMode = false
    
    var delegate: WritingBuyButtonDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
        
        let tap = UILongPressGestureRecognizer(target: self, action: "tappedMe:")
        tap.minimumPressDuration = 0.0
        
        self.addGestureRecognizer(tap)
    }
    
    override func drawRect(rect: CGRect) {
        if state == 0 {
            let priceLow = writings[writingIndex].getPrice(1).0
            let priceHigh = writings[writingIndex].getPrice(1).1
            var text = "\(priceLow) - \(priceHigh) Letters"
            let color = nightMode ? UIColor.lightTextColor() : UIColor.blackColor()
            
            TapStyle.drawBuy(frame: rect, colorBuyBorder: color, colorBuyText: color, buyText: text)
        }
    }
    
    
    func tappedMe(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            UIView.animateWithDuration(0.15, animations: {
                self.transform = CGAffineTransformMakeScale(0.91, 0.91)
            })
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            self.delegate?.buyTapped(self.writingIndex)
            
            UIView.animateWithDuration(0.35, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                self.transform = CGAffineTransformIdentity
                }, completion: { (Bool) -> Void in
                    
            })
        }
    }
}