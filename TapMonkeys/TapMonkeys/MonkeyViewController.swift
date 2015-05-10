//
//  MonkeyViewController.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/9/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

struct MonkeyData {
    var index: Int = -1
    var name: String = "ERROR MONKEY"
    var description: String = "This abomination should have never been birthed"
    var lettersPerSecond: Int = 0
    var modifiers: [(Float, Float)] = [(-1, -1)]
    var costs: [(Float, Float)] = [(-1, -1)]
    var unlockCost: [(Float, Float)] = [(-1, -1)]
    
    var unlocked: Bool = false
    var count: Int = 0
    var modifier: Int = 0
    
    func lettersPerSecondCumulative() -> Int {
        return count * lettersPerSecond
    }
}

class MonkeyViewController: UIViewController {
    @IBOutlet weak var dataHeader: DataHeader!
    
    var monkeyTable: MonkeyTableViewController?
    
    var defaults: NSUserDefaults?
    var saveData: SaveData?
    var monkeys: [MonkeyData]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaults = NSUserDefaults.standardUserDefaults()
        saveData = load()
        
        loadMonkeys()
        configureMonkeys()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func loadMonkeys() {
        let path = NSBundle.mainBundle().pathForResource("monkeys", ofType: "dat")!
        let content = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)! as String
        let splitContent = split(content) { $0 == "\n" }
        
        monkeys = [MonkeyData]()
        
        for i in 0...splitContent.count / 5 - 1 {
            var newMonkey = MonkeyData()
            
            for x in 0...5 {
                let data = splitContent[i * 6 + x]
                
                // Name
                if x == 0 {
                    newMonkey.name = data
                }
                // Description
                else if x == 1 {
                    newMonkey.description = data
                }
                // Letters/sec
                else if x == 2 {
                    newMonkey.lettersPerSecond = data.toInt()!
                }
                // Unlock requirements
                else if x == 3 {
                    newMonkey.unlockCost = parseFloatTuples(data)
                }
                // Modifiers
                else if x == 4 {
                    newMonkey.modifiers = parseFloatTuples(data)
                }
                // Unlock cost overrides
                else if x == 5 {
                    newMonkey.costs = parseFloatTuples(data)
                }
            }
            
            monkeys.append(newMonkey)
        }
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
        
        monkeyTable!.monkeys = monkeys
    }
    
    // Parses a string in this format: 0 - 0 | 1 - 1
    // Into an array of tuples: [(0, 0), (1, 1)]
    func parseFloatTuples(string: String) -> [(Float, Float)] {
        let cleanString = string.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var final = [(Float, Float)]()
        var tupleStrings = split(cleanString) { $0 == "|" }
        
        for tuple in tupleStrings {
            let tupleString = split(tuple) { $0 == "-" }
            
            final.append((tupleString[0].floatValue, tupleString[1].floatValue))
        }
        
        return final
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueMonkeyTable" {
            if let dest = segue.destinationViewController as? MonkeyTableViewController {
                monkeyTable = dest
            }
        }
    }
}

class MonkeyTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    var monkeys = [MonkeyData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 250
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
            if let blurView = cell.viewWithTag(8) as? UIVisualEffectView {
                // We're good to go I guess
            }
            else {
                let blur = UIBlurEffect(style: UIBlurEffectStyle.Light)
                var blurView = UIVisualEffectView(effect: blur)
                
                blurView.frame = cell.contentView.frame
                blurView.tag = 8
                
                cell.contentView.addSubview(blurView)
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
            
            monkeyPic.monkeyIndex = index
            monkeyPic.setNeedsDisplay()
            
            name.text = curMonkey.name
            owned.text = "Owned: \(curMonkey.count)"
            frequency.text = "Letters/sec: \(curMonkey.lettersPerSecondCumulative())"
            
            
            return cell
        }
        else {
            println("Unable to load monkey cell / subviews!")
        }
        
        return UITableViewCell()
    }
}

class MonkeyPicture: UIView {
    var monkeyIndex = 0
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        if monkeyIndex == 0 {
            TapStyle.drawFingerMonkey()
        }
    }
}

class MonkeyBuyButton: UIView {
    // 0 is 1 only, 1 is 1 | 10, 2 is 1 | 10 | 100
    var state = 0
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        if state == 0 {
            TapStyle.drawBuy1(frame: rect, monkeyBuyText: "FREE")
        }
    }
}

class MonkeyLockView: UIView {
    var locked = true
    var blurView: UIVisualEffectView
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    var unlock
}