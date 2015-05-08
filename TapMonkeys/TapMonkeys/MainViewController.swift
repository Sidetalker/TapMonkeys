//
//  ViewController.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/8/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import QuartzCore

class MainViewController: UIViewController {
    @IBOutlet weak var startT: PopLabel!
    @IBOutlet weak var startA: PopLabel!
    @IBOutlet weak var startP: PopLabel!
    
    var firstRun = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configure() {
        configureGestureRecognizers()
        prepareForDisplay()
    }
    
    func configureGestureRecognizers() {
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("singleTapMain:"))
        let tapHold = UILongPressGestureRecognizer(target: self, action: Selector("holdMain:"))
        
        self.view.addGestureRecognizer(singleTap)
        self.view.addGestureRecognizer(tapHold)
    }
    
    func prepareForDisplay() {
        startT.setChar("T")
        startA.setChar("A")
        startP.setChar("P")
    }
    
    func singleTapMain(sender: UITapGestureRecognizer) {
        if firstRun {
            startT.pop(true)
            startA.pop(true)
            startP.pop(true)
            
            firstRun = false
            
            return
        }
        
        let tapLoc = sender.locationOfTouch(0, inView: self.view)
        let frame = CGRect(origin: CGPoint(x: tapLoc.x - 12, y: tapLoc.y - 12), size: CGSize(width: 25, height: 25))
        let popLabel = PopLabel(frame: frame, character: "Z")
        popLabel.backgroundColor = UIColor.clearColor()
        
        self.view.addSubview(popLabel)
        popLabel.pop(true)
    }
    
    func holdMain(sender: UILongPressGestureRecognizer) {
        
    }
}

