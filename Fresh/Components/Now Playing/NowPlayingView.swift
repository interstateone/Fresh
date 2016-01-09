//
//  NowPlayingView.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-12-30.
//  Copyright © 2015 Brandon Evans. All rights reserved.
//

import Foundation

@objc protocol NowPlayingView {
    var trackTitle: String { get set }
    var author: String { get set }
    var progress: Double { get set }
    var duration: Double { get set }
    var formattedProgress: String { get set }
    var formattedDuration: String { get set }
    var favorite: Bool { get set }
    var hidden: Bool { get set }
    var waveform: FSHWaveform { get set }
    var playing: Bool { get set }
    var loading: Bool { get set }
    var permalinkURL: NSURL { get set }
}
