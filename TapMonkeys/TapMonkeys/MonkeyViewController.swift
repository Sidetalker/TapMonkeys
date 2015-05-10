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
    var modifiers: [(Float, Float)] = [(-1, -1)]
    var costs: [(Float, Float)] = [(-1, -1)]
    var unlockCost: [(Float, Float)] = [(-1, -1)]
    
    var unlocked: Bool = false
    var count: Int = 0
    var modifier: Int = 0
}

class MonkeyViewController: UIViewController {
    @IBOutlet weak var dataHeader: DataHeader!
    
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
                let data = splitContent[i * 5 + x]
                
                // Name
                if x == 0 {
                    newMonkey.name = data
                }
                // Description
                else if x == 1 {
                    newMonkey.description = data
                }
                // Unlock requirements
                else if x == 2 {
                    newMonkey.unlockCost = parseFloatTuples(data)
                }
                // Modifiers
                else if x == 3 {
                    newMonkey.modifiers = parseFloatTuples(data)
                }
                // Unlock cost overrides
                else if x == 4 {
                    newMonkey.costs = parseFloatTuples(data)
                }
                // Newline
                else if x == 5 {
                    // Don't do jack fucking shit
                }
            }
            
            monkeys.append(newMonkey)
        }
    }
    
    func configureMonkeys() {
        
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
}

class MonkeyTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class MonkeyPicture: UIView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        TapStyle.drawFingerMonkey()
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