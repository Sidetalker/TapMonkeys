//
//  TapStyle.swift
//  TapMonkeys
//
//  Created by Kevin Sullivan on 5/10/15.
//  Copyright (c) 2015 SideApps. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//



import UIKit

public class TapStyle : NSObject {

    //// Drawing Methods

    public class func drawMainLetter(#character: String) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Letter Drawing
        let letterRect = CGRectMake(0, -0, 28, 28)
        let letterStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        letterStyle.alignment = NSTextAlignment.Center

        let letterFontAttributes = [NSFontAttributeName: UIFont(name: "Noteworthy-Light", size: 27)!, NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: letterStyle]

        let letterTextHeight: CGFloat = NSString(string: character).boundingRectWithSize(CGSizeMake(letterRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: letterFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, letterRect);
        NSString(string: character).drawInRect(CGRectMake(letterRect.minX, letterRect.minY + (letterRect.height - letterTextHeight) / 2, letterRect.width, letterTextHeight), withAttributes: letterFontAttributes)
        CGContextRestoreGState(context)
    }

    public class func drawFingerMonkey() {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()


        //// Shadow Declarations
        let monkeyPicShadow = NSShadow()
        monkeyPicShadow.shadowColor = UIColor.blackColor()
        monkeyPicShadow.shadowOffset = CGSizeMake(0.1, -0.1)
        monkeyPicShadow.shadowBlurRadius = 3

        //// Image Declarations
        let monkeyA = UIImage(named: "monkeyA.jpg")!

        //// Oval Drawing
        var ovalPath = UIBezierPath(ovalInRect: CGRectMake(5, 5, 90, 90))
        CGContextSaveGState(context)
        CGContextSetPatternPhase(context, CGSizeMake(4, 5))
        UIColor(patternImage: monkeyA).setFill()
        ovalPath.fill()
        CGContextRestoreGState(context)
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, monkeyPicShadow.shadowOffset, monkeyPicShadow.shadowBlurRadius, (monkeyPicShadow.shadowColor as! UIColor).CGColor)
        UIColor.blackColor().setStroke()
        ovalPath.lineWidth = 0.5
        ovalPath.stroke()
        CGContextRestoreGState(context)
    }

    public class func drawBuy1(#frame: CGRect, monkeyBuyText: String) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Rectangle Drawing
        let rectangleRect = CGRectMake(frame.minX + 5, frame.minY + 5, floor((frame.width - 5) * 0.97959 + 0.5), floor((frame.height - 5) * 0.88889 + 0.5))
        let rectanglePath = UIBezierPath(roundedRect: rectangleRect, cornerRadius: 10)
        UIColor.blackColor().setStroke()
        rectanglePath.lineWidth = 1
        rectanglePath.stroke()
        let rectangleStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        rectangleStyle.alignment = NSTextAlignment.Center

        let rectangleFontAttributes = [NSFontAttributeName: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 14)!, NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: rectangleStyle]

        let rectangleTextHeight: CGFloat = NSString(string: monkeyBuyText).boundingRectWithSize(CGSizeMake(rectangleRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: rectangleFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, rectangleRect);
        NSString(string: monkeyBuyText).drawInRect(CGRectMake(rectangleRect.minX, rectangleRect.minY + (rectangleRect.height - rectangleTextHeight) / 2, rectangleRect.width, rectangleTextHeight), withAttributes: rectangleFontAttributes)
        CGContextRestoreGState(context)
    }

}

@objc protocol StyleKitSettableImage {
    func setImage(image: UIImage!)
}

@objc protocol StyleKitSettableSelectedImage {
    func setSelectedImage(image: UIImage!)
}
