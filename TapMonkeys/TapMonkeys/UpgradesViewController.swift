//
//  UpgradesViewController.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/18/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

class UpgradesViewController: UIViewController {
    @IBOutlet weak var dataHeader: DataHeader!
    
    var upgradesTable: UpgradesTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueUpgradesTable" {
            upgradesTable = segue.destinationViewController as? UpgradesTableViewController
        }
    }
}

class UpgradesTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    var collapseFlags = [true, true, true]
    var upgrades = [
        [   "Tap A",
            "Mega Tap"
        ],
        [   "Noice",
            "Blaster",
            "Fang",
            "Killer",
            "Pikaschie"
        ],
        [   "Tibbyt",
            "Frag",
            "Libel"
        ]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(getRowTypes())
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if isSectionRow(indexPath.row) {
            if let
                cell = tableView.dequeueReusableCellWithIdentifier("cellSection") as? UITableViewCell,
                img = cell.viewWithTag(1) as? UIImageView,
                title = cell.viewWithTag(2) as? UILabel,
                lock = cell.viewWithTag(3) as? UIImageView
            {
                lock.alpha = 0.0
                
                return cell
            }
        }
        else {
            if let
                cell = tableView.dequeueReusableCellWithIdentifier("cellUpgrade") as? UITableViewCell,
                title = cell.viewWithTag(1) as? UILabel
            {
                title =
            }
            
        }
        
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        return
    }
    
    func isSectionRow(row: Int) -> Bool {
        return getRowTypes()[row]
    }
    
    // Return an array of booleans - true are "section" cells
    func getRowTypes() -> [Bool] {
        var rowCount = [Bool]()
        
        for i in 0...count(upgrades) - 1 {
            rowCount.append(true)
            
            if !collapseFlags[i] {
                for upgrade in 0...count(upgrades[i]) - 1 {
                    rowCount.append(false)
                }
            }
        }
        
        return rowCount
    }
}