//
//  WaveformSliderView.swift
//  Fresh
//
//  Created by Brandon Evans on 2016-01-10.
//  Copyright © 2016 Brandon Evans. All rights reserved.
//

import Cocoa

class WaveformSliderView: NSControl {
    var maskImage: NSImage? = nil
    var waveform: Waveform? = nil {
        didSet {
            guard let waveform = waveform else { return }
            
            guard let offscreenRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(bounds.width), pixelsHigh: Int(bounds.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSDeviceRGBColorSpace, bitmapFormat: NSBitmapFormat.NSAlphaFirstBitmapFormat, bytesPerRow: 0, bitsPerPixel: 0) else {
                return
            }
            
            // Set offscreen context
            guard let graphicsContext = NSGraphicsContext(bitmapImageRep: offscreenRep) else { return }
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.setCurrentContext(graphicsContext)
            
            let context = graphicsContext.CGContext
            CGContextSetFillColorWithColor(context, NSColor.blackColor().CGColor)
            let width = bounds.size.width / CGFloat(waveform.values.count)
            let maxValue = CGFloat(waveform.values.maxElement() ?? 1)
            for (index, value) in waveform.values.enumerate() {
                let rect = CGRectIntegral(CGRectMake(CGFloat(index) * width, 0, width, CGFloat(value) / maxValue * bounds.size.height))
                CGContextFillRect(context, rect)
            }
            
            NSGraphicsContext.restoreGraphicsState()
            
            let waveformImage = NSImage(size:bounds.size)
            waveformImage.addRepresentation(offscreenRep)
            
            maskImage = waveformImage
        }
    }
    var maxValue: Double = 0 {
        didSet {
            guard let cell = cell as? WaveformSliderCell else { return }
            maxValue = max(maxValue, 0)
            cell.maxValue = maxValue
            setNeedsDisplay()
        }
    }
    override var doubleValue: Double {
        set {
            var _doubleValue = max(newValue, 0)
            _doubleValue = min(newValue, maxValue)
            cell?.objectValue = _doubleValue
            super.doubleValue = _doubleValue
            setNeedsDisplay()
        }
        get {
            return super.doubleValue
        }
    }

    override static func cellClass() -> AnyClass {
        return WaveformSliderCell.self
    }

    override func drawRect(dirtyRect: NSRect) {
        cell?.drawWithFrame(bounds, inView: self)
    }

    override func mouseDown(event: NSEvent) {
        let mousePoint = convertPoint(event.locationInWindow, fromView: nil)
        if let cell = cell as? WaveformSliderCell where cell.knobPath().containsPoint(mousePoint) {
            trackMouseWithStartPoint(mousePoint)
        }
        else if CGRectContainsPoint(bounds, mousePoint) {
            doubleValue = Double(valueForPoint(mousePoint))
            NSApp.sendAction(action, to:target, from:self)
            trackMouseWithStartPoint(mousePoint)
        }
    }

    private func valueForPoint(point: NSPoint) -> CGFloat {
        return point.x / CGRectGetWidth(bounds) * CGFloat(maxValue)
    }
    
    private func trackMouseWithStartPoint(point: NSPoint) {
        // Compute the value offset: this makes the pointer stay on the same piece of the knob when dragging
        let valueOffset = Double(valueForPoint(point)) - (objectValue as? NSNumber ?? NSNumber(double: 0)).doubleValue
        
        var event: NSEvent?
        while event?.type != .LeftMouseUp {
            event = window?.nextEventMatchingMask(Int(NSEventMask.LeftMouseDraggedMask.rawValue) | Int(NSEventMask.LeftMouseUpMask.rawValue))
            guard let event = event else { continue }

            let eventLocation = convertPoint(event.locationInWindow, fromView: nil)
            let value = Double(valueForPoint(eventLocation))
            doubleValue = value - valueOffset
            NSApp.sendAction(action, to: target, from: self)
        }

    }
}
