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

struct SaveData {
    var stage: Int?
    var letters: Int?
    var money: Float?
    var letterCounts: [Int]?
    
    var monkeyUnlocks: [Bool]?
    var monkeyCounts: [Int]?
    var monkeyTotals: [Int]?
    var monkeyLastCost: [Int]?
    var monkeyLastMod: [Float]?
}

struct WritingData {
    var index: Int = -1
    var name: String = "ERROR WRITETHING"
    var description: String = "kill.....me"
    var costLow: Int = -1
    var costHigh: Int = -1
    var costLowOffset: Int = -1
    var costHighOffset: Int = -1
    
    var count: Int = 0
    var unlocked: Bool = false
    var level: Int = 1
    
    // Return (lettersLow, lettersHigh)
    func getPrice(count: Int) -> (Int, Int) {
        let low = costLow + costLowOffset
        let high = costHigh + costHighOffset
        
        return (low * count, high * count)
    }
}

func loadWritings(data: SaveData) {
    let path = NSBundle.mainBundle().pathForResource("monkeys", ofType: "dat")!
    let content = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)! as String
    let splitContent = split(content) { $0 == "\n" }
    
    writings = [WritingData]()
    
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
    
    for i in 0...count(monkeys) - 1 {
        monkeys[i].previousCost = data.monkeyLastCost![i]
        monkeys[i].previousMod = data.monkeyLastMod![i]
        monkeys[i].count = data.monkeyCounts![i]
        monkeys[i].index = i
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
    var previousCost: Int = -1
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
        return Int(Float(self.count * self.lettersPerSecond) * timeInterval)
    }
    
    func canPurchase(count: Int, data: SaveData) -> Bool {
        if data.letters >= getPrice(count).0 {
            return true
        }
        
        return false
    }
    
    mutating func purchase(count: Int, data: SaveData) -> SaveData? {
        var curData = data
        let pricing = getPrice(count)
        
        curData.letters! -= pricing.0
        curData.monkeyCounts![index] += count
        curData.monkeyLastCost![index] = pricing.1
        curData.monkeyLastMod![index] = pricing.2
        
        self.count += count
        self.previousCost = pricing.1
        self.previousMod = pricing.2
        
        return curData
    }
    
    // Return (totalCost, previousSingleCost, previousMod)
    func getPrice(count: Int) -> (Int, Int, Float) {
        var costBuffer = previousCost
        var modBuffer = previousMod
        var totalCost = 0
        
        if costBuffer == -1 {
            costBuffer = Int(costs[self.index].0)
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
            
            curCost = Int(ceil(Float(curCost) * curMod))
            
            costBuffer = curCost
            modBuffer = curMod
            
            totalCost += curCost
        }
        
        println("\(totalCost, costBuffer, modBuffer)")
        return (totalCost, costBuffer, modBuffer)
    }
    
    func costOverride() -> Int {
        for cost in costs {
            if self.count == Int(cost.0) {
                return Int(cost.1)
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
    
    for i in 0...count(monkeys) - 1 {
        monkeys[i].previousCost = data.monkeyLastCost![i]
        monkeys[i].previousMod = data.monkeyLastMod![i]
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