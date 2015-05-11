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

struct SaveData {
    var stage: Int?
    var letters: Int?
    var money: Float?
    var letterCounts: [Int]?
    
    var monkeyUnlocks: [Bool]?
    var monkeyCounts: [Int]?
}

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