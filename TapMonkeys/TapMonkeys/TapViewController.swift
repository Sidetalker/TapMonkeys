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

class TapViewController: UIViewController, PopLabelDelegate {
    @IBOutlet weak var tapLabel: UILabel!
    @IBOutlet weak var letterCountLabel: UILabel!
    
    var tabBar: TabBarController!
    
    var stage = -1
    var genLabels = [PopLabel]()
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
        
    }
    
    override func viewDidLayoutSubviews() {
        tabBar = self.tabBarController as? TabBarController
//        tabBar.setTabBarVisible(false, animated: false)
//        tabBar.hide()
    }
    
    func prepGen(index: Int) {
        gen = gens[index]
        genPoints = [CGPoint]()
        
        let genWidth = CGFloat(count(gen) * 28)
        let gapWidth = self.view.frame.width - genWidth
        let frameMod = gapWidth / CGFloat((count(gen) + 1))
        let size = CGSize(width: 28, height: 28)
        let yLoc: CGFloat = 100.0
        
        var curFrameMod = frameMod
        
        for letter in gen {
            genPoints.append(CGPoint(x: curFrameMod, y: yLoc))
            
            curFrameMod += frameMod + size.width
        }
    }
    
    func singleTapMain(sender: UITapGestureRecognizer) {
        // Tap till we have a monkey
        if stage == -1 {
            UIView.animateWithDuration(0.6, animations: { () -> Void in
                self.tapLabel.alpha = 0.0
                self.tapLabel.transform = CGAffineTransformMakeScale(1.35, 1.35)
                }, completion: { (Bool) -> Void in
                    self.stage = 0
                    self.prepGen(0)
            })
        }
        else if stage == 0 {
            let tapLoc = sender.locationOfTouch(0, inView: self.view)
            let frame = CGRect(origin: CGPoint(x: tapLoc.x - 14, y: tapLoc.y - 14), size: CGSize(width: 28, height: 28))
            let letter = alphabet[randomIntBetweenNumbers(0, 26)]
            let popLabel = PopLabel(frame: frame, character: letter)
            popLabel.backgroundColor = UIColor.clearColor()
            popLabel.delegate = self
            
            self.view.addSubview(popLabel)
            
            if contains(gen, letter) {
                let index = find(gen, letter)!
                
                popLabel.pop(remove: false, customEnd: true, customPoint: genPoints[index], noEnd: true)
                
                gen.removeAtIndex(index)
                genPoints.removeAtIndex(index)
                genLabels.append(popLabel)
                
                delay(2.0, {
                    if self.gen.count == 0 {
                        for i in 0...count(self.genLabels) - 1 {
                            self.genLabels[i].move(CGPoint(x: 10, y: self.genLabels[i].frame.origin.y), scale: 0.3, alpha: 0.0, duration: 0.4, delay: Double(i) * 0.1, remove: true)
                        }
                    }
                })
            }
            else {
//                popLabel.move(CGPoint(x: 10, y: 10), scale: 0.3, alpha: 0.0, duration: 0.4, delay: 0.0, remove: true, pulse: true)
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

