//
//  Timer.swift
//  Fresh
//
//  Created by Brandon Evans on 2016-01-08.
//  Copyright © 2016 Brandon Evans. All rights reserved.
//

import Foundation

/// Single use timer that can be used from Swift without @objc

class Timer {
    private let timer: NSTimer
    
    init(interval: Double, tolerance: Double? = nil, repeats: Bool = false, handler: () -> Void) {
        let wrapper = TimerHandlerWrapper(handler: handler)
        self.timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: wrapper, selector: "timerFired", userInfo: nil, repeats: repeats)
        if let tolerance = tolerance {
            timer.tolerance = tolerance
        }
    }

    func stop() {
        timer.invalidate()
    }
}

private class TimerHandlerWrapper {
    private let handler: () -> Void

    init(handler: () -> Void) {
        self.handler = handler
    }

    @objc func timerFired() {
        handler()
    }
}
