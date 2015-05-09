//
//  Helpers.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/8/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import QuartzCore

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
    defaults.setObject(data.state, forKey: "stage")
    
    return true
}

func load() -> SaveData {
    let defaults = NSUserDefaults.standardUserDefaults()
    var save = SaveData()
    
    save.letters = defaults.integerForKey("letters")
    save.money = defaults.floatForKey("money")
    save.letterCounts = defaults.arrayForKey("letterCounts")
    save.state = defaults.arrayForKey("stage")
    
    return save
}