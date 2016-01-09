//
//  NowPlayingViewController.swift
//  Fresh
//
//  Created by Brandon Evans on 2016-01-08.
//  Copyright © 2016 Brandon Evans. All rights reserved.
//

import Cocoa

struct NowPlayingViewState {
    var trackTitle: String = ""
    var author: String = ""
    var progress: Double = 0
    var duration: Double = 0
    var formattedProgress: String = ""
    var formattedDuration: String = ""
    var favorite: Bool = false
    var hidden: Bool = true
    var waveform: FSHWaveform? = nil
    var playing: Bool = false
    var loading: Bool = false
    var permalinkURL: NSURL? = nil
}

protocol NowPlayingView {
    var state: NowPlayingViewState { get set }
}

class NowPlayingViewController: NSTitlebarAccessoryViewController, NowPlayingView, NSSharingServicePickerDelegate {
    @IBOutlet var masterPlayButton: NSButton!
    @IBOutlet var trackLabel: NSTextField!
    @IBOutlet var authorLabel: NSTextField!
    @IBOutlet var favoriteButton: NSButton!
    @IBOutlet var shareButton: NSButton!
    @IBOutlet var progressLabel: NSButton!
    @IBOutlet var durationLabel: NSButton!
    @IBOutlet var waveformSlider: FSHWaveformSliderView!

    var presenter: NowPlayingPresenter?
    var eventMonitor: AnyObject?

    // MARK: -

    override func loadView() {
        super.loadView()

        shareButton.sendActionOn(Int(NSEventMask.LeftMouseDownMask.rawValue))
        progressLabel.cell?.backgroundStyle = .Lowered
        durationLabel.cell?.backgroundStyle = .Lowered
        
        if let presenter = presenter {
            masterPlayButton.target = presenter
            masterPlayButton.action = Selector("toggleCurrentSound")
            favoriteButton.target = presenter
            favoriteButton.action = Selector("toggleFavorite")
        }

        waveformSlider.target = self
        waveformSlider.action = Selector("waveformSliderChanged:")

        let eventHandler = { [weak self] (event: NSEvent) -> NSEvent? in
            guard event.window == self?.view.window else { return event }
            
            var result: NSEvent? = event
            // Space bar
            // See HIToolbox/Events.h for reference
            if (event.keyCode == 49) {
                self?.presenter?.toggleCurrentSound()
                result = nil
            }

            return result
        }
        eventMonitor = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask, handler: eventHandler)
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        presenter?.initializeView()
        refreshUI(state)
    }
    
    deinit {
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
    }

    // MARK: Actions

    func waveformSliderChanged(slider: FSHWaveformSliderView) {
        if let progress = slider.objectValue as? NSNumber {
            presenter?.seekToProgress(progress.doubleValue)
        }
    }

    func shareCurrentSound(sender: NSControl) {
        let shareText = "Listening to \(state.trackTitle) by \(state.author) with Fresh."
        let picker = NSSharingServicePicker(items: [shareText])
        picker.delegate = self
        picker.showRelativeToRect(NSZeroRect, ofView: sender, preferredEdge: .MaxX)
    }

    // MARK: NSSharingServicePickerDelegate

    func sharingServicePicker(sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [AnyObject], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
        return [
            NSSharingService(named: NSSharingServiceNamePostOnTwitter),
            NSSharingService(named: NSSharingServiceNamePostOnFacebook),
            NSSharingService(named: NSSharingServiceNamePostOnSinaWeibo),
            NSSharingService(named: NSSharingServiceNamePostOnTencentWeibo),
            NSSharingService(title: "View on SoundCloud", image: NSImage(named: "SoundCloudLogoSmall")!, alternateImage: nil) { [weak self] in
                guard let _self = self, permalinkURL = _self.state.permalinkURL else { return }
                NSWorkspace.sharedWorkspace().openURL(permalinkURL)
            }
        ].flatMap { $0 }.filter { $0.canPerformWithItems(items) }
    }

    // MARK: NowPlayingView
    
    var state = NowPlayingViewState() {
        didSet {
            refreshUI(state)
        }
    }
    
    private func refreshUI(state: NowPlayingViewState) {
        if !viewLoaded { return }

        trackLabel.stringValue = state.trackTitle
        authorLabel.stringValue = state.author
        waveformSlider.doubleValue = state.progress
        waveformSlider.maxValue = state.duration
        progressLabel.stringValue = state.formattedProgress
        durationLabel.stringValue = state.formattedDuration
        favoriteButton.image = state.favorite ? NSImage(named: "FavoriteActive") : NSImage(named: "Favorite")
        view.hidden = state.hidden
        masterPlayButton.image = state.playing ? NSImage(named: "PauseButton") : NSImage(named: "PlayButton")
        waveformSlider.waveform = state.waveform
    }
}
