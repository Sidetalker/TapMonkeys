//
//  ViewController.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/8/15.
//  Copyright (c) 2015 Kevin Sullivan. All rights reserved.
//

import UIKit
import QuartzCore

let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

let gens = [
    ["M", "O", "N", "K", "E", "Y", "S"]
]

class MainViewController: UIViewController, PopLabelDelegate {
    @IBOutlet weak var startT: PopLabel!
    @IBOutlet weak var startA: PopLabel!
    @IBOutlet weak var startP: PopLabel!
    @IBOutlet weak var letterCountLabel: UILabel!
    
    var stage = -1
    var genPoints = [CGPoint]()
    var gen = [String]()
    var letterCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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
        
        startT.delegate = self
        startA.delegate = self
        startP.delegate = self
    }
    
    func prepGen(index: Int) {
        gen = gens[index]
        genPoints = [CGPoint]()
        
        let genWidth = CGFloat(count(gen) * 28)
        let gapWidth = self.view.frame.width - genWidth
        let frameMod = gapWidth / CGFloat((count(gen) + 1))
        let size = CGSize(width: 28, height: 28)
        
        var curFrameMod = frameMod
        
        for letter in gen {
            genPoints.append(CGPoint(x: curFrameMod, y: frameMod))
            
            curFrameMod += frameMod + size.width
        }
    }
    
    func singleTapMain(sender: UITapGestureRecognizer) {
        // Pop away the tap instructions
        if stage == -1 {
            startT.pop()
            startA.pop()
            startP.pop()
            
            stage = 0
            
            return
        }
        else if stage == 0 {
            prepGen(0)
            stage = 1
        }
        else if stage == 1 {
            let tapLoc = sender.locationOfTouch(0, inView: self.view)
            let frame = CGRect(origin: CGPoint(x: tapLoc.x - 14, y: tapLoc.y - 14), size: CGSize(width: 28, height: 28))
            let letter = alphabet[randomIntBetweenNumbers(0, 26)]
            let popLabel = PopLabel(frame: frame, character: letter)
            popLabel.backgroundColor = UIColor.clearColor()
            popLabel.delegate = self
            
            self.view.addSubview(popLabel)
            
            if contains(gen, letter) {
                let index = find(gen, letter)!
                
                popLabel.pop(remove: false, customEnd: true, customPoint: genPoints[index])
                
                gen.removeAtIndex(index)
                genPoints.removeAtIndex(index)
                
            }
            else {
                popLabel.pop()
            }
        }
    }
    
    func holdMain(sender: UILongPressGestureRecognizer) {
        
    }
    
    func finishedPopping(customEnd: Bool) {
        if customEnd { return }
        
        letterCount++
        letterCountLabel.text = "\(letterCount)"
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.letterCountLabel.transform = CGAffineTransformMakeScale(1.35, 1.35)
            self.letterCountLabel.alpha = 1.0
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.letterCountLabel.transform = CGAffineTransformIdentity
                    }, completion: nil)
        })
    }
}

