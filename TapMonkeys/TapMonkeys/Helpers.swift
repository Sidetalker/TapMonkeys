//
//  Helpers.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/8/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import QuartzCore

var currencyFormatter = NSNumberFormatter()
var generalFormatter = NSNumberFormatter()

func initializeFormatters() {
    currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
    generalFormatter.numberStyle = NSNumberFormatterStyle.NoStyle
    generalFormatter.usesGroupingSeparator = true
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
    defaults.setObject(data.nightMode, forKey: "nightMode")
    
    defaults.setObject(data.monkeyUnlocks, forKey: "monkeyUnlocks")
    defaults.setObject(data.monkeyCounts, forKey: "monkeyCounts")
    defaults.setObject(data.monkeyTotals, forKey: "monkeyTotals")
    defaults.setObject(data.monkeyLastCost, forKey: "monkeyLastCost")
    defaults.setObject(data.monkeyLastMod, forKey: "monkeyLastMod")
    defaults.setObject(data.monkeyCollapsed, forKey: "monkeyCollapsed")
    
    defaults.setObject(data.writingCount, forKey: "writingCount")
    defaults.setObject(data.writingUnlocked, forKey: "writingUnlocked")
    defaults.setObject(data.writingLevel, forKey: "writingLevel")
    defaults.setObject(data.writingCostLow, forKey: "writingCostLow")
    defaults.setObject(data.writingCostHigh, forKey: "writingCostHigh")
    defaults.setObject(data.writingCollapsed, forKey: "writingCollapsed")
    
    defaults.setObject(data.incomeUnlocks, forKey: "incomeUnlocks")
    defaults.setObject(data.incomeCounts, forKey: "incomeCounts")
    defaults.setObject(data.incomeTotals, forKey: "incomeTotals")
    defaults.setObject(data.incomeLastCost, forKey: "incomeLastCost")
    defaults.setObject(data.incomeLastMod, forKey: "incomeLastMod")
    defaults.setObject(data.incomeLevel, forKey: "incomeLevel")
    defaults.setObject(data.incomeCollapsed, forKey: "incomeCollapsed")
    
    defaults.synchronize()
    
    return true
}

func readDefaults() -> SaveData {
    let defaults = NSUserDefaults.standardUserDefaults()
    var save = SaveData()
    
    save.letters = defaults.floatForKey("letters")
    save.money = defaults.floatForKey("money")
    save.letterCounts = defaults.arrayForKey("letterCounts") as? [Float]
    save.stage = defaults.integerForKey("stage")
    save.nightMode = defaults.boolForKey("nightMode")
    
    save.monkeyUnlocks = defaults.arrayForKey("monkeyUnlocks") as? [Bool]
    save.monkeyCounts = defaults.arrayForKey("monkeyCounts") as? [Int]
    save.monkeyTotals = defaults.arrayForKey("monkeyTotals") as? [Float]
    save.monkeyLastCost = defaults.arrayForKey("monkeyLastCost") as? [Float]
    save.monkeyLastMod = defaults.arrayForKey("monkeyLastMod") as? [Float]
    save.monkeyCollapsed = defaults.arrayForKey("monkeyCollapsed") as? [Bool]
    
    save.writingCount = defaults.arrayForKey("writingCount") as? [Int]
    save.writingUnlocked = defaults.arrayForKey("writingUnlocked") as? [Bool]
    save.writingLevel = defaults.arrayForKey("writingLevel") as? [Int]
    save.writingCostLow = defaults.arrayForKey("writingCostLow") as? [Int]
    save.writingCostHigh = defaults.arrayForKey("writingCostHigh") as? [Int]
    save.writingCollapsed = defaults.arrayForKey("writingCollapsed") as? [Bool]
    
    save.incomeUnlocks = defaults.arrayForKey("incomeUnlocks") as? [Bool]
    save.incomeCounts = defaults.arrayForKey("incomeCounts") as? [Int]
    save.incomeTotals = defaults.arrayForKey("incomeTotals") as? [Float]
    save.incomeLastCost = defaults.arrayForKey("incomeLastCost") as? [Float]
    save.incomeLastMod = defaults.arrayForKey("incomeLastMod") as? [Float]
    save.incomeLevel = defaults.arrayForKey("incomeLevel") as? [Int]
    save.incomeCollapsed = defaults.arrayForKey("incomeCollapsed") as? [Bool]
    
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
    let numMonkeys = 7
    let numWriting = 7
    let numIncome = 7
    
    var newSave = save
    
    if newSave.letterCounts == nil {
        newSave.letterCounts = [Float](count: numLetterCounts, repeatedValue: 0)
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
        newSave.monkeyTotals = [Float](count: numMonkeys, repeatedValue: 0)
    }
    else if count(newSave.monkeyTotals!) < numMonkeys {
        for i in count(newSave.monkeyTotals!)...numMonkeys - 1 {
            newSave.monkeyTotals?.append(0)
        }
    }
    
    if newSave.monkeyLastCost == nil {
        newSave.monkeyLastCost = [Float](count: numMonkeys, repeatedValue: 0.0)
    }
    else if count(newSave.monkeyLastCost!) < numMonkeys {
        for i in count(newSave.monkeyLastCost!)...numMonkeys - 1 {
            newSave.monkeyLastCost?.append(0)
        }
    }
    
    if newSave.monkeyCollapsed == nil {
        newSave.monkeyCollapsed = [Bool](count: numMonkeys, repeatedValue: false)
    }
    else if count(newSave.monkeyCollapsed!) < numMonkeys {
        for i in count(newSave.monkeyCollapsed!)...numMonkeys - 1 {
            newSave.monkeyCollapsed?.append(false)
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
    
    if newSave.writingCount == nil {
        newSave.writingCount = [Int](count: numWriting, repeatedValue: 0)
    }
    else if count(newSave.writingCount!) < numWriting {
        for i in count(newSave.writingCount!)...numWriting - 1 {
            newSave.writingCount?.append(0)
        }
    }
    
    if newSave.writingUnlocked == nil {
        newSave.writingUnlocked = [Bool](count: numWriting, repeatedValue: false)
    }
    else if count(newSave.writingUnlocked!) < numWriting {
        for i in count(newSave.writingUnlocked!)...numWriting - 1 {
            newSave.writingUnlocked?.append(false)
        }
    }
    
    if newSave.writingLevel == nil {
        newSave.writingLevel = [Int](count: numWriting, repeatedValue: 1)
    }
    else if count(newSave.writingLevel!) < numWriting {
        for i in count(newSave.writingLevel!)...numWriting - 1 {
            newSave.writingLevel?.append(1)
        }
    }
    
    if newSave.writingCostLow == nil {
        newSave.writingCostLow = [Int](count: numWriting, repeatedValue: 0)
    }
    else if count(newSave.writingCostLow!) < numWriting {
        for i in count(newSave.writingCostLow!)...numWriting - 1 {
            newSave.writingCostLow?.append(0)
        }
    }
    
    if newSave.writingCostHigh == nil {
        newSave.writingCostHigh = [Int](count: numWriting, repeatedValue: 0)
    }
    else if count(newSave.writingCostHigh!) < numWriting {
        for i in count(newSave.writingCostHigh!)...numWriting - 1 {
            newSave.writingCostHigh?.append(0)
        }
    }
    
    if newSave.writingCollapsed == nil {
        newSave.writingCollapsed = [Bool](count: numWriting, repeatedValue: false)
    }
    else if count(newSave.writingCollapsed!) < numWriting {
        for i in count(newSave.writingCollapsed!)...numWriting - 1 {
            newSave.writingCollapsed?.append(false)
        }
    }
    
    if newSave.incomeUnlocks == nil {
        newSave.incomeUnlocks = [Bool](count: numIncome, repeatedValue: false)
    }
    else if count(newSave.incomeUnlocks!) < numIncome {
        for i in count(newSave.incomeUnlocks!)...numIncome - 1 {
            newSave.incomeUnlocks?.append(false)
        }
    }
    
    if newSave.incomeCounts == nil {
        newSave.incomeCounts = [Int](count: numIncome, repeatedValue: 0)
    }
    else if count(newSave.incomeCounts!) < numIncome {
        for i in count(newSave.incomeCounts!)...numIncome - 1 {
            newSave.incomeCounts?.append(0)
        }
    }
    
    if newSave.incomeTotals == nil {
        newSave.incomeTotals = [Float](count: numIncome, repeatedValue: 0)
    }
    else if count(newSave.incomeTotals!) < numIncome {
        for i in count(newSave.incomeTotals!)...numIncome - 1 {
            newSave.incomeTotals?.append(0)
        }
    }
    
    if newSave.incomeLastCost == nil {
        newSave.incomeLastCost = [Float](count: numIncome, repeatedValue: 0)
    }
    else if count(newSave.incomeLastCost!) < numIncome {
        for i in count(newSave.incomeLastCost!)...numIncome - 1 {
            newSave.incomeLastCost?.append(0)
        }
    }
    
    if newSave.incomeLastMod == nil {
        newSave.incomeLastMod = [Float](count: numIncome, repeatedValue: 0)
    }
    else if count(newSave.incomeLastMod!) < numIncome {
        for i in count(newSave.incomeLastMod!)...numIncome - 1 {
            newSave.incomeLastMod?.append(0)
        }
    }
    
    if newSave.incomeLevel == nil {
        newSave.incomeLevel = [Int](count: numIncome, repeatedValue: 0)
    }
    else if count(newSave.incomeLevel!) < numIncome {
        for i in count(newSave.incomeLevel!)...numIncome - 1 {
            newSave.incomeLevel?.append(0)
        }
    }
    
    if newSave.incomeCollapsed == nil {
        newSave.incomeCollapsed = [Bool](count: numIncome, repeatedValue: false)
    }
    else if count(newSave.incomeCollapsed!) < numIncome {
        for i in count(newSave.incomeCollapsed!)...numIncome - 1 {
            newSave.incomeCollapsed?.append(false)
        }
    }
    
    return newSave
}

func individualLettersPer(timeInterval: Float) -> [Float] {
    var lettersPer = [Float]()
    
    for monkey in monkeys {
        lettersPer.append(monkey.lettersPer(timeInterval))
    }
    
    return lettersPer
}

func fullLettersPer(timeInterval: Float) -> Float {
    var lettersPer: Float = 0
    
    for monkey in monkeys {
        lettersPer += monkey.lettersPer(timeInterval)
    }
    
    return lettersPer
}

func monkeyProductionTimer() -> Float {
    var highestLPS: Float = 0
    
    for monkey in monkeys {
        let LPS = monkey.lettersPerSecondCumulative()
        
        if LPS > highestLPS && LPS > 0 {
            highestLPS = monkey.lettersPerSecondCumulative()
        }
    }
    
    if highestLPS == 0 {
        return 1.0
    }
    
    return 1.0 / highestLPS
}

func individualIncomePer(timeInterval: Float) -> [Float] {
    var incomePer = [Float]()
    
    for income in incomes {
        incomePer.append(income.moneyPer(timeInterval))
    }
    
    return incomePer
}

func fullIncomePer(timeInterval: Float) -> Float {
    var moneyPer: Float = 0
    
    for income in incomes {
        moneyPer += income.moneyPer(timeInterval)
    }
    
    return moneyPer
}

func incomeProductionTimer() -> Float {
    var highestIPS: Float = 0
    
    for income in incomes {
        let IPS = income.moneyPerSecond()
        
        if IPS > highestIPS && IPS > 0 {
            highestIPS = income.moneyPerSecond()
        }
    }
    
    if highestIPS == 0 {
        return 1.0
    }
    
    return 1.0 / (highestIPS * 100)
}








