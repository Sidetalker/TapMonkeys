//
//  MonkeyViewController.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/9/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

struct MonkeyData {
    var index: Int?
    var name: String?
    var description: String?
    var modifiers: [(Int, Float)]?
    var costs: [(Int, Float)]?
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
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func loadMonkeys() {
        
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