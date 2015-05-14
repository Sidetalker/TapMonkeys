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
    
    var writingTable: WritingViewController?
    
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
        if segue.identifier == "segueWritingTable" {
            writingTable = segue.destinationViewController as? WritingViewController
        }
    }
}

class WritingTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, AnimatedLockDelegate, WritingBuyButtonDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 232
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return count(writings) == 0 ? 0 : 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(writings)
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
            cell = tableView.dequeueReusableCellWithIdentifier("cellWriting") as? UITableViewCell,
            pic = cell.viewWithTag(1) as? WritingPicture,
            title = cell.viewWithTag(2) as? UILabel,
            owned = cell.viewWithTag(3) as? UILabel,
            value = cell.viewWithTag(4) as? UILabel,
            level = cell.viewWithTag(5) as? UILabel,
            button = cell.viewWithTag(6) as? WritingBuyButton,
            description = cell.viewWithTag(7) as? UILabel
        {
            let index = indexPath.row
            let moneyText = NSString(format: "%.2f", writings[index].getValue()) as String
            
            pic.writingIndex = index
            title.text = writings[index].name
            description.text = writings[index].description
            owned.text = "Owned: \(writings[index].count)"
            value.text = "Value: $\(moneyText)"
            level.text = "Level: \(writings[index].level)"
            button.writingIndex = index
            
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

class WritingPicture: UIView {
    var writingIndex = 0
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
        
        self.setNeedsDisplay()
    }
    
    init(frame: CGRect, strokeWidth: CGFloat) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        if writingIndex == 0 {
            TapStyle.drawWords()
        }
        else if writingIndex == 1 {
            TapStyle.drawFragmentedSentence()
        }
        else if writingIndex == 2 {
            TapStyle.drawSentence()
        }
        else if writingIndex == 3 {
            TapStyle.drawTextMessage()
        }
        else if writingIndex == 4 {
            TapStyle.drawTweet()
        }
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
            self.delegate?.buyTapped(self.writingIndex)
            
            UIView.animateWithDuration(0.35, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                self.transform = CGAffineTransformIdentity
                }, completion: { (Bool) -> Void in
                    
            })
        }
    }
}