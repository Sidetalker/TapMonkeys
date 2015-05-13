//
//  Helpers.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/8/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import QuartzCore

class ConstraintView: UIView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
    }
}

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

func delay(delay: Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func randomFloatBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
    return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
}

func randomIntBetweenNumbers(firstNum: Int, secondNum: Int) -> Int {
    let first = CGFloat(firstNum)
    let second = CGFloat(secondNum)
    let random = randomFloatBetweenNumbers(first, second)
    
    return Int(random)
}

func save(sender: AnyObject?, data: SaveData) -> Bool {
    if let controller = sender as? TabBarController {
        writeDefaults(data)
        controller.saveData = data
        
        return true
    }
    else {
        println("Error saving - sender is not a TabBarController")
        return false
    }
}

func load(sender: AnyObject?) -> SaveData {
    if let controller = sender as? TabBarController {
        return controller.saveData
    }
    else {
        println("Error loading - sender is not a TabBarController")
        return SaveData()
    }
}

func writeDefaults(data: SaveData) -> Bool {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    defaults.setObject(data.letters, forKey: "letters")
    defaults.setObject(data.money, forKey: "money")
    defaults.setObject(data.letterCounts, forKey: "letterCounts")
    defaults.setObject(data.stage, forKey: "stage")
    
    defaults.setObject(data.monkeyUnlocks, forKey: "monkeyUnlocks")
    defaults.setObject(data.monkeyCounts, forKey: "monkeyCounts")
    defaults.setObject(data.monkeyTotals, forKey: "monkeyTotals")
    defaults.setObject(data.monkeyLastCost, forKey: "monkeyLastCost")
    defaults.setObject(data.monkeyLastMod, forKey: "monkeyLastMod")
    
    defaults.synchronize()
    
    return true
}

func readDefaults() -> SaveData {
    let defaults = NSUserDefaults.standardUserDefaults()
    var save = SaveData()
    
    save.letters = defaults.integerForKey("letters")
    save.money = defaults.floatForKey("money")
    save.letterCounts = defaults.arrayForKey("letterCounts") as? [Int]
    save.stage = defaults.integerForKey("stage")
    
    save.monkeyUnlocks = defaults.arrayForKey("monkeyUnlocks") as? [Bool]
    save.monkeyCounts = defaults.arrayForKey("monkeyCounts") as? [Int]
    save.monkeyTotals = defaults.arrayForKey("monkeyTotals") as? [Int]
    save.monkeyLastCost = defaults.arrayForKey("monkeyLastCost") as? [Int]
    save.monkeyLastMod = defaults.arrayForKey("monkeyLastMod") as? [Float]
    
    return save
}

func updateGlobalSave(save: SaveData) {
    var curSave = save
    let dataWrapper = NSData(bytes: &curSave, length: sizeof(SaveData))
    
    let nc = NSNotificationCenter.defaultCenter()
    nc.postNotificationName("updateSave", object: nil, userInfo: [
        "saveData" : dataWrapper
        ])
}

func validate(save: SaveData) -> SaveData {
    let numLetterCounts = 26
    let numMonkeys = 1
    
    var newSave = save
    
    if newSave.letterCounts == nil {
        newSave.letterCounts = [Int](count: numLetterCounts, repeatedValue: 0)
    }
    else if count(newSave.letterCounts!) < numLetterCounts {
        for i in count(newSave.letterCounts!)...numLetterCounts - 1 {
            newSave.letterCounts?.append(0)
        }
    }
    
    if newSave.monkeyCounts == nil {
        newSave.monkeyCounts = [Int](count: numMonkeys, repeatedValue: 0)
    }
    else if count(newSave.monkeyCounts!) < numMonkeys {
        for i in count(newSave.monkeyCounts!)...numMonkeys - 1 {
            newSave.monkeyCounts?.append(0)
        }
    }
    
    if newSave.monkeyUnlocks == nil {
        newSave.monkeyUnlocks = [Bool](count: numMonkeys, repeatedValue: false)
    }
    else if count(newSave.monkeyUnlocks!) < numMonkeys {
        for i in count(newSave.monkeyUnlocks!)...numMonkeys - 1 {
            newSave.monkeyUnlocks?.append(false)
        }
    }
    
    if newSave.monkeyTotals == nil {
        newSave.monkeyTotals = [Int](count: numMonkeys, repeatedValue: 0)
    }
    else if count(newSave.monkeyTotals!) < numMonkeys {
        for i in count(newSave.monkeyTotals!)...numMonkeys - 1 {
            newSave.monkeyTotals?.append(0)
        }
    }
    
    if newSave.monkeyLastCost == nil {
        newSave.monkeyLastCost = [Int](count: numMonkeys, repeatedValue: 0)
    }
    else if count(newSave.monkeyLastCost!) < numMonkeys {
        for i in count(newSave.monkeyLastCost!)...numMonkeys - 1 {
            newSave.monkeyLastCost?.append(0)
        }
    }
    
    if newSave.monkeyLastMod == nil {
        newSave.monkeyLastMod = [Float](count: numMonkeys, repeatedValue: 0.0)
    }
    else if count(newSave.monkeyLastMod!) < numMonkeys {
        for i in count(newSave.monkeyLastMod!)...numMonkeys - 1 {
            newSave.monkeyLastMod?.append(0.0)
        }
    }
    
    return newSave
}

func fullLettersPer(timeInterval: Float) -> Int {
    var lettersPer = 0
    
    for monkey in monkeys {
        lettersPer += monkey.lettersPer(timeInterval)
    }
    
    return lettersPer
}

func monkeyProductionTimer() -> Float {
    var lowestLettersPerSecond = 1000
    
    for monkey in monkeys {
        if monkey.lettersPerSecondCumulative() < lowestLettersPerSecond {
            lowestLettersPerSecond = monkey.lettersPerSecondCumulative()
        }
    }
    
    if lowestLettersPerSecond == 0 {
        return 1
    }
    
    return 1.0 / Float(lowestLettersPerSecond)
}








