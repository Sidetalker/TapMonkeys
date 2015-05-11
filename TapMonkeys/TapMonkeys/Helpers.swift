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

func save(data: SaveData) -> Bool {
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
    
    return true
}

func load() -> SaveData {
    let defaults = NSUserDefaults.standardUserDefaults()
    var save = SaveData()
    
    save.letters = defaults.integerForKey("letters")
    save.money = defaults.floatForKey("money")
    save.letterCounts = defaults.arrayForKey("letterCounts") as? [Int]
    save.stage = defaults.integerForKey("stage")
    
    save.monkeyUnlocks = defaults.arrayForKey("monkeyUnlocks") as? [Bool]
    save.monkeyCounts = defaults.arrayForKey("monkeyCounts") as? [Int]
    save.monkeyTotals = defaults.arrayForKey("monkeyTotals") as? [Int]
    save.monkeyLastCost = defaults.integerForKey("monkeyLastCount")
    save.monkeyLastMod = defaults.floatForKey("monkeyLastMod")
    
    return save
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
    
    return newSave
}