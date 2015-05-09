//
//  MonkeyViewController.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/9/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

class MonkeyViewController: UIViewController {
    
}

class MonkeyTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
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
            TapStyle.drawBuy1(frame: rect)
        }
    }
}