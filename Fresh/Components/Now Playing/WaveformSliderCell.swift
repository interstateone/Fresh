//
//  WaveformSliderCell.swift
//  Fresh
//
//  Created by Brandon Evans on 2016-01-10.
//  Copyright © 2016 Brandon Evans. All rights reserved.
//

import Cocoa

class WaveformSliderCell: NSActionCell {
    static let KnobRadius: Double = 5

    var maxValue: Double = 0

    func knobPath() -> NSBezierPath {
        let doubleValue = (objectValue as? NSNumber ?? NSNumber(double: 0)).doubleValue
        var x = ceil(doubleValue / maxValue * Double(CGRectGetWidth(controlView?.frame ?? CGRectZero))) - WaveformSliderCell.KnobRadius
        if maxValue == 0 {
            x = -WaveformSliderCell.KnobRadius
        }
        let knobPath = NSBezierPath()
        knobPath.moveToPoint(NSPoint(x: x, y: 0))
        let y = sqrt(pow(WaveformSliderCell.KnobRadius, 2.0) - pow(WaveformSliderCell.KnobRadius / 2.0, 2.0))
        knobPath.lineToPoint(NSPoint(x: x + WaveformSliderCell.KnobRadius, y: y))
        knobPath.lineToPoint(NSPoint(x: x + WaveformSliderCell.KnobRadius * 2.0, y: 0))
        knobPath.closePath()
        return knobPath
    }

    override func drawWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        super.drawWithFrame(cellFrame, inView: controlView)
        
        guard let sliderView = controlView as? WaveformSliderView else { return }
        if sliderView.waveform == nil { return }
        
        drawWaveformInRect(sliderView.bounds, inView: sliderView, enabled: sliderView.window?.keyWindow ?? false)
        drawKnob(sliderView.bounds)
    }
    
    func drawWaveformInRect(rect: NSRect, inView controlView: WaveformSliderView, enabled: Bool) {
        guard let graphicsContext = NSGraphicsContext.currentContext() else { return }
        let context = graphicsContext.CGContext
        
        graphicsContext.saveGraphicsState()
        
        if graphicsContext.flipped {
            CGContextTranslateCTM(context, 0.0, rect.size.height)
            CGContextScaleCTM(context, 1.0, -1.0)
        }

        // Create mask image
        var maskRect = rect
        let maskImage = controlView.maskImage?.CGImageForProposedRect(&maskRect, context: graphicsContext, hints: nil)
        CGContextClipToMask(context, NSRectToCGRect(maskRect), maskImage)
        
        // Draw gradient
        var startColor = NSColor(deviceWhite: 0.46, alpha: 1.0)
        var endColor = NSColor(deviceWhite:0.25, alpha:1.0)

        if (!enabled) {
            startColor = startColor.colorWithAlphaComponent(0.5)
            endColor = endColor.colorWithAlphaComponent(0.5)
        }
        
        // Draw inner gradient
        let gradient = NSGradient(startingColor:startColor, endingColor: endColor)
        gradient?.drawInRect(maskRect, angle:90.0)
        
        // Draw progress gradient
        startColor = NSColor(calibratedRed:1.0, green:0.49, blue:0.0, alpha:1.0)
        endColor = NSColor(calibratedRed:1.0, green:0.0, blue:0.0, alpha:1.0)
        
        if !enabled {
            startColor = startColor.colorWithAlphaComponent(0.5)
            endColor = endColor.colorWithAlphaComponent(0.5)
        }

        let doubleValue = (objectValue as? NSNumber ?? NSNumber(double: 0)).doubleValue
        let progressRect = CGRectIntegral(CGRectMake(0, 0, rect.size.width * CGFloat(doubleValue / self.maxValue), rect.size.height))
        let progressGradient = NSGradient(startingColor: startColor, endingColor: endColor)
        progressGradient?.drawInRect(progressRect, angle: 90.0)
        
        graphicsContext.restoreGraphicsState()
    }
    
    func drawKnob(rect: NSRect) {
        let shadow = NSShadow()
        shadow.shadowColor = .blackColor()
        shadow.shadowOffset = NSSize(width: 0, height: -2)
        shadow.shadowBlurRadius = 5
        shadow.set()
        NSColor.whiteColor().setFill()
        knobPath().fill()
    }
}
