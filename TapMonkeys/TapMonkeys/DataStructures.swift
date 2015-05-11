//
//  DataStructures.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/11/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

let gens = [
    ["M", "O", "N", "K", "E", "Y", "S"],
    ["W", "R", "I", "T", "I", "N", "G"]
]

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