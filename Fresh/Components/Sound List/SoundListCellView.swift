//
//  SoundListCellView.swift
//  Fresh
//
//  Created by Brandon Evans on 2016-01-08.
//  Copyright © 2016 Brandon Evans. All rights reserved.
//

import Cocoa

class SoundListCellView: NSTableCellView {
    @IBOutlet var trackNameField: NSTextField!
    @IBOutlet var authorNameField: NSTextField!
    @IBOutlet var playingImageView: NSImageView!
    
    var playing: Bool = false {
        didSet {
            playingImageView.hidden = !playing
        }
    }

    override var backgroundStyle: NSBackgroundStyle {
        didSet {
            guard let row = superview as? NSTableRowView else { return }

            if row.selected {
                trackNameField.textColor = .whiteColor()
                authorNameField.textColor = .whiteColor()
            }
            else {
                trackNameField.textColor = .blackColor()
                authorNameField.textColor = .darkGrayColor()
            }
        }
    }
}
