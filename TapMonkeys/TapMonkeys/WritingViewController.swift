//
//  WritingViewController.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/13/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit

class WritingViewController: UIViewController {
    @IBOutlet weak var dataHeader: DataHeader!
    
    var writingTable: WritingViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWriting()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueWritingTable" {
            writingTable = segue.destinationViewController as? WritingViewController
        }
    }
    
    func configureWriting() {
        
    }
}

class WritingTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 250
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("cellWriting") as? UITableViewCell {
            return cell
        }
        
        return UITableViewCell()
    }
}