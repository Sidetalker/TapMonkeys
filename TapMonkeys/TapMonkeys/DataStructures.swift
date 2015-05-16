//
//  DataStructures.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/11/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

// Introduction Stage Descriptions
// 0: First launch - tap image is displayed
// 1: Spelling MONKEY
// 2: MONKEY has been spelled
// 3: The monkey tab has been selected
// 4: The free monkey has been unlocked

import Foundation

let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

let gens = [
    ["M", "O", "N", "K", "E", "Y", "S"],
    ["W", "R", "I", "T", "I", "N", "G"]
]

var monkeys = [MonkeyData]()
var writings = [WritingData]()
var incomes = [IncomeData]()

struct SaveData {
    var stage: Int?
    var letters: Int?
    var money: Float?
    var letterCounts: [Int]?
    
    var monkeyUnlocks: [Bool]?
    var monkeyCounts: [Int]?
    var monkeyTotals: [Int]?
    var monkeyLastCost: [Float]?
    var monkeyLastMod: [Float]?
    
    var writingCount: [Int]?
    var writingUnlocked: [Bool]?
    var writingLevel: [Int]?
    var writingCostLow: [Int]?
    var writingCostHigh: [Int]?
    
    var incomeUnlocks: [Bool]?
    var incomeCounts: [Int]?
    var incomeTotals: [Float]?
    var incomeLevel: [Int]?
    var incomeLastCost: [Float]?
    var incomeLastMod: [Float]?
}

struct IncomeData {
    var index: Int = -1
    var name: String = "ERROR WRITETHING"
    var description: String = "kill.....me"
    var unlockCost = [(Float, Float)]()
    var costs = [(Float, Float)]()
    var modifiers = [(Float, Float)]()
    
    var previousMod: Float = -1
    var previousCost: Float = -1
    var count: Int = 0
    var unlocked: Bool = false
    var moneyProduced = [(Float, Float)]()
    var totalProduced: Float = 0
    var level: Int = 0
    
    mutating func purchase(count: Int, data: SaveData) -> SaveData? {
        var curData = data
        let price = getPrice(count)
        println("\(index)")
        
        if writings[self.index].count >= Int(price.0) {
            self.previousCost = price.1
            self.previousMod = price.2
            self.count += count
            
            writings[self.index].count -= Int(price.0)
            
            curData.writingCount![self.index] -= Int(price.0)
            curData.incomeCounts![self.index] += count
            curData.incomeLastCost![self.index] = price.1
            curData.incomeLastMod![self.index] = price.2
            
            return curData
        }
        
        return nil
    }
    
    func moneyPer(interval: Float) -> Float {
        var preciseInterval = Float(self.count) * self.getProduction() * interval
        
        return preciseInterval
    }
    
    func moneyPerSecond() -> Float {
        return Float(count) * getProduction()
    }
    
    func getProduction() -> Float {
        for item in moneyProduced {
            if Int(item.0) == level {
                return item.1
            }
        }
        
        return moneyProduced[moneyProduced.count - 1].1
    }
    
    func getPurchaseString(count: Int) -> String {
        let price = Int(getPrice(count).0)
        let itemName = writings[Int(unlockCost[0].0)].name
        let plurarity = price > 1 ? true : false
        
        return "\(price) \(itemName)s"
    }
    
    // Return (total cost, last cost, last mod)
    func getPrice(count: Int) -> (Float, Float, Float) {
        var costBuffer = previousCost
        var modBuffer = previousMod
        var totalCost: Float = 0
        
        if costBuffer == -1 {
            costBuffer = costs[self.index].0
        }
        if modBuffer == -1 {
            modBuffer = modifiers[self.index].0
        }
        
        for i in 0...count - 1 {
            let curCostOverride = costOverride()
            let curModOverride = modOverride()
            
            var curCost = costBuffer
            var curMod = modBuffer
            
            if curCostOverride >= 0 {
                curCost = curCostOverride
            }
            if curModOverride >= 0 {
                curMod = curModOverride
            }
            
            curCost = curCost * (curCostOverride == -1 ? curMod : 1)
            
            costBuffer = curCost
            modBuffer = curMod
            
            totalCost += curCost
        }
        
        return (totalCost, costBuffer, modBuffer)
    }
    
    func costOverride() -> Float {
        for cost in costs {
            if self.count == Int(cost.0) {
                return cost.1
            }
        }
        
        return -1
    }
    
    func modOverride() -> Float {
        for mod in modifiers {
            if self.count == Int(mod.0) {
                return mod.1
            }
        }
        
        return -1
    }
}

func loadIncome(data: SaveData) {
    let path = NSBundle.mainBundle().pathForResource("income", ofType: "dat")!
    let content = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)! as String
    let splitContent = split(content) { $0 == "\n" }
    
    incomes = [IncomeData]()
    
    for i in 0...splitContent.count / 6 - 1 {
        var newIncome = IncomeData()
        
        for x in 0...5 {
            let data = splitContent[i * 6 + x]
            
            // Name
            if x == 0 {
                newIncome.name = data
            }
                // Description
            else if x == 1 {
                newIncome.description = data
            }
                // Unlock requirements
            else if x == 2 {
                newIncome.unlockCost = parseFloatTuples(data)
            }
                // Unlock costs
            else if x == 3 {
                newIncome.costs = parseFloatTuples(data)
            }
                // Modifiers
            else if x == 4 {
                newIncome.modifiers = parseFloatTuples(data)
            }
                // Unlock cost overrides
            else if x == 5 {
                newIncome.moneyProduced = parseFloatTuples(data)
            }
        }
        
        incomes.append(newIncome)
    }
    
    for i in 0...count(incomes) - 1 {
        incomes[i].previousCost = data.incomeLastCost![i]
        incomes[i].previousMod = data.incomeLastMod![i]
        incomes[i].unlocked = data.incomeUnlocks![i]
        incomes[i].count = data.incomeCounts![i]
        incomes[i].level = data.incomeLevel![i]
        incomes[i].index = i
    }
}

struct WritingData {
    var index: Int = -1
    var name: String = "ERROR WRITETHING"
    var description: String = "kill.....me"
    var unlockCost: Int = -1
    var costLow: Int = -1
    var costHigh: Int = -1
    var costLowOffset: Int = -1
    var costHighOffset: Int = -1
    
    var count: Int = 0
    var unlocked: Bool = false
    var values = [Float]()
    var level: Int = 1
    
    // Return (lettersLow, lettersHigh, lettersRandom)
    func getPrice(count: Int) -> (Int, Int, Int) {
        let low = costLow + costLowOffset
        let high = costHigh + costHighOffset
        let random = randomIntBetweenNumbers(low, high)
        
        return (low * count, high * count, random)
    }
    
    func getValue() -> Float {
        return values[level - 1] * Float(count)
    }
    
    mutating func purchase(count: Int, data: SaveData) -> SaveData? {
        var curData = data
        let price = getPrice(count)
        
        if curData.letters! >= count * price.1 {
            var curPrice = 0
            
            for i in 0...count - 1 {
                curPrice += randomIntBetweenNumbers(price.0, price.1)
            }
            
            curData.letters! -= curPrice
            curData.writingCount![index] += count
            curData.writingCostLow![index] = costLowOffset
            curData.writingCostHigh![index] = costHighOffset
            
            self.count += count
            
            return curData
        }
        
        return nil
    }
}

func loadWritings(data: SaveData) {
    let path = NSBundle.mainBundle().pathForResource("writing", ofType: "dat")!
    let content = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)! as String
    let splitContent = split(content) { $0 == "\n" }
    
    writings = [WritingData]()
    
    for i in 0...splitContent.count / 6 - 1 {
        var entry = WritingData()
        
        for x in 0...5 {
            let data = splitContent[i * 6 + x]
            
                // Name
            if x == 0 {
                entry.name = data
            }
                // Description
            else if x == 1 {
                entry.description = data
            }
                // Value
            else if x == 2 {
                let result = parseFloatTuples(data)
                
                for value in result {
                    entry.values.append(value.1)
                }
            }
                // Letters/sec
            else if x == 3 {
                entry.unlockCost = data.toInt()!
            }
                // Unlock requirements
            else if x == 4 {
                entry.costLow = data.toInt()!
            }
                // Modifiers
            else if x == 5 {
                entry.costHigh = data.toInt()!
            }
        }
        
        writings.append(entry)
    }
    
    for i in 0...count(writings) - 1 {
        writings[i].count = data.writingCount![i]
        writings[i].unlocked = data.writingUnlocked![i]
        writings[i].level = data.writingLevel![i]
        writings[i].costLowOffset = data.writingCostLow![i]
        writings[i].costHighOffset = data.writingCostHigh![i]
        writings[i].index = i
    }
}

struct MonkeyData {
    var index: Int = -1
    var name: String = "ERROR MONKEY"
    var description: String = "This abomination should have never been birthed"
    var lettersPerSecond: Int = 0
    var modifiers: [(Float, Float)] = [(-1, -1)]
    var costs: [(Float, Float)] = [(-1, -1)]
    var unlockCost: [(Float, Float)] = [(-1, -1)]
    
    var previousMod: Float = -1
    var previousCost: Float = -1
    var unlocked: Bool = false
    var count: Int = 0
    var modifier: Float = 0
    var totalProduced: Int = 0
    
    func lettersPerSecondCumulative() -> Int {
        return count * lettersPerSecond
    }
    
    func lettersTotal() -> Int {
        return totalProduced
    }
    
    func lettersPer(timeInterval: Float) -> Int {
        var preciseInterval = Float(self.count * self.lettersPerSecond) * timeInterval
        
        if preciseInterval < 1 { return 0 }
        
        return Int(preciseInterval)
    }
    
    func canPurchase(count: Int, data: SaveData) -> Bool {
        if data.money! >= getPrice(count).0 {
            return true
        }
        
        return false
    }
    
    mutating func purchase(count: Int, data: SaveData) -> SaveData? {
        var curData = data
        let pricing = getPrice(count)
        
        curData.money! -= pricing.0
        curData.monkeyCounts![index] += count
        curData.monkeyLastCost![index] = pricing.1
        curData.monkeyLastMod![index] = pricing.2
        
        self.count += count
        self.previousCost = pricing.1
        self.previousMod = pricing.2
        
        return curData
    }
    
    // Return (totalCost, previousSingleCost, previousMod)
    func getPrice(count: Int) -> (Float, Float, Float) {
        var costBuffer = previousCost
        var modBuffer = previousMod
        var totalCost: Float = 0
        
        if costBuffer == -1 {
            costBuffer = costs[self.index].0
        }
        if modBuffer == -1 {
            modBuffer = modifiers[self.index].0
        }
        
        for i in 0...count - 1 {
            let curCostOverride = costOverride()
            let curModOverride = modOverride()
            
            var curCost = costBuffer
            var curMod = modBuffer
            
            if curCostOverride >= 0 {
                curCost = curCostOverride
            }
            if curModOverride >= 0 {
                curMod = curModOverride
            }
            
            curCost = curCost * curMod
            
            costBuffer = curCost
            modBuffer = curMod
            
            totalCost += curCost
        }
        
        return (totalCost, costBuffer, modBuffer)
    }
    
    func costOverride() -> Float {
        for cost in costs {
            if self.count == Int(cost.0) {
                return cost.1
            }
        }
        
        return -1
    }
    
    func modOverride() -> Float {
        for mod in modifiers {
            if self.count == Int(mod.0) {
                return mod.1
            }
        }
        
        return -1
    }
}

func loadMonkeys(data: SaveData) {
    let path = NSBundle.mainBundle().pathForResource("monkeys", ofType: "dat")!
    let content = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)! as String
    let splitContent = split(content) { $0 == "\n" }
    
    monkeys = [MonkeyData]()
    
    for i in 0...splitContent.count / 6 - 1 {
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
    
    for i in 0...count(monkeys) - 1 {
        monkeys[i].previousCost = data.monkeyLastCost![i]
        monkeys[i].previousMod = data.monkeyLastMod![i]
        monkeys[i].unlocked = data.monkeyUnlocks![i]
        monkeys[i].count = data.monkeyCounts![i]
        monkeys[i].index = i
    }
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