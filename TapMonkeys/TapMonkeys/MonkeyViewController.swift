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
    
    var defaults: NSUserDefaults?
    var saveData: SaveData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaults = NSUserDefaults.standardUserDefaults()
        saveData = load()
        
        configureMonkeys()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func configureMonkeys() {
        let totalMonkeys = count(monkeys)
        let monkeyCounts = saveData!.monkeyCounts!
        let monkeyUnlocks = saveData!.monkeyUnlocks!
        
        if totalMonkeys != count(monkeyCounts) {
            println("Houston, we have a problem")
        }
        
        for i in 0...totalMonkeys - 1 {
            monkeys[i].unlocked = monkeyUnlocks[i]
            monkeys[i].count = monkeyCounts[i]
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueMonkeyTable" {
            if let dest = segue.destinationViewController as? MonkeyTableViewController {
                monkeyTable = dest
            }
        }
    }
}

class MonkeyTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, MonkeyLockDelegate, MonkeyBuyButtonDelegate {
    var defaults: NSUserDefaults?
    var saveData: SaveData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 250
        
        defaults = NSUserDefaults.standardUserDefaults()
        saveData = load()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return count(monkeys) == 0 ? 0 : 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(monkeys) == 0 ? 0 : count(monkeys)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        let curMonkey = monkeys[index]
        
        if !curMonkey.unlocked {
            if let lockView = cell.viewWithTag(8) as? MonkeyLockView {
                // We're good to go I guess
            }
            else {
                let lockView = MonkeyLockView(frame: cell.contentView.frame)
                lockView.tag = 8
                lockView.index = indexPath.row
                lockView.delegate = self
                
                cell.contentView.addSubview(lockView)
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
            total = cell.viewWithTag(5) as? UILabel,
            buyButton = cell.viewWithTag(6) as? MonkeyBuyButton,
            description = cell.viewWithTag(7) as? UILabel
        {
            let index = indexPath.row
            let curMonkey = monkeys[index]
            let curPrice = curMonkey.getPrice(1).0
            
            buyButton.monkeyIndex = index
            monkeyPic.monkeyIndex = index
            monkeyPic.setNeedsDisplay()
            
            buyButton.delegate = self
            buyButton.setNeedsDisplay()
            
            name.text = curMonkey.name
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
    
    func tappedLock(view: MonkeyLockView) {
        let index = view.index
        
        if index == 0 && saveData!.stage == 3 {
            saveData!.stage = 4
            save(saveData!)
            
            view.unlock()
            monkeys[index].unlocked = true
        }
    }
    
    func buyTapped(monkeyIndex: Int) {
        var monkey = monkeys[monkeyIndex]
        
        if monkeyIndex == 0 && saveData!.stage == 4 {
            if monkey.canPurchase(1, data: saveData!) {
                var price = monkey.getPrice(1).0 * -1
                
                saveData = monkey.purchase(1, data: load())
                
                if let
                    monkeyCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: monkeyIndex, inSection: 0)),
                    monkeyPic = monkeyCell.viewWithTag(1) as? MonkeyPicture
                {
//                    monkeyPic.getFunky()
                }
                
                monkeys[monkeyIndex] = monkey
                
                delay(0.2, {
                    self.tableView.reloadData()
                    
                    let nc = NSNotificationCenter.defaultCenter()
                    nc.postNotificationName("updateHeaders", object: self, userInfo: [
                        "letters" : price,
                        "animated" : false
                        ])
                })
            }
        }
    }
}

class MonkeyPicture: UIView {
    var monkeyIndex = 0
    var strokeWidth: CGFloat = 1
    
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
            TapStyle.drawFingerMonkey(monkeyStrokeWidth: strokeWidth)
        }
    }
    
    func getFunky() {
        let viewTwo = MonkeyPicture(frame: CGRect(origin: CGPointZero, size: self.frame.size), strokeWidth: 0.0)
        
        self.addSubview(viewTwo)
        
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            viewTwo.transform = CGAffineTransformMakeScale(1.2, 1.2)
            viewTwo.alpha = 0.0
            }, completion: { (Bool) -> Void in
                viewTwo.removeFromSuperview()
        })
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
        if state == 0 {
            let price = monkeys[monkeyIndex].getPrice(1).0
            var text = "FREE"
            
            if price > 0 {
                text = "$\(price)"
            }
            
            TapStyle.drawBuy1(frame: rect, monkeyBuyText: text)
        }
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

protocol MonkeyLockDelegate {
    func tappedLock(view: MonkeyLockView)
}

class MonkeyLockView: UIView {
    @IBOutlet var nibView: UIView!
    @IBOutlet weak var lockImage: UIImageView!
    @IBOutlet weak var requirementsText: UILabel!
    @IBOutlet weak var staticText: UILabel!
    
    var locked = true
    var index = -1
    var blurView: UIVisualEffectView!
    var animator: UIDynamicAnimator?
    var delegate: MonkeyLockDelegate?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    func configure() {
        NSBundle.mainBundle().loadNibNamed("MonkeyLockView", owner: self, options: nil)
        
        nibView.frame = self.frame
        
        self.addSubview(nibView)
        
        let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
        blurView = UIVisualEffectView(effect: blur)
        
        blurView.frame = self.frame
        blurView.tag = 1
        
        self.backgroundColor = UIColor.clearColor()
        
        self.nibView.addSubview(blurView)
        self.nibView.sendSubviewToBack(blurView)
        
        var animationImages = [UIImage]()
        
        for i in 1...12 {
            let imageName = "monkeyLock" + (NSString(format: "%02d", i) as String)
            
            if let image = UIImage(named: imageName) {
                animationImages.append(image)
            }
            else {
                println("Error: Unable to load all images for monkey lock sequence")
                break
            }
        }
        
        lockImage.animationImages = animationImages
        lockImage.animationDuration = 0.35
        lockImage.animationRepeatCount = 1
        
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("lockTap:"))
        
        self.addGestureRecognizer(singleTap)
    }
    
    func lockTap(sender: UITapGestureRecognizer) {
        delegate?.tappedLock(self)
    }
    
    func unlock() {
        lockImage.image = UIImage(named: "monkeyLock12")
        
        lockImage.startAnimating()
        
        let angularVelocityLock: CGFloat = 0.4
        let linearVelocityLock = CGPoint(x: 25, y: -150)
        
        // Set up the gravitronator
        let gravity = UIGravityBehavior(items: [lockImage])
        let velocity = UIDynamicItemBehavior(items: [lockImage])
        
        gravity.gravityDirection = CGVectorMake(0, 0.4)
        
        velocity.addAngularVelocity(angularVelocityLock, forItem: lockImage)
        velocity.addLinearVelocity(linearVelocityLock, forItem: lockImage)
        
        animator = UIDynamicAnimator(referenceView: self.nibView)
        animator?.addBehavior(velocity)
        animator?.addBehavior(gravity)
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: nil, animations: { () -> Void in
            self.requirementsText.alpha = 0.0
            self.staticText.alpha = 0.0
            }, completion: { (Bool) -> Void in
                
        })
        
        UIView.animateWithDuration(1.1, delay: 0.2, options: nil, animations: { () -> Void in
            self.blurView?.alpha = 0.0
            }, completion: { (Bool) -> Void in
                self.removeFromSuperview()
        })
        
        UIView.animateWithDuration(0.51, delay: 0.39, options: nil, animations: { () -> Void in
            self.lockImage.alpha = 0.0
            }, completion: { (Bool) -> Void in
                
        })
    }
}