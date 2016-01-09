//
//  NowPlayingPresenter.swift
//  Fresh
//
//  Created by Brandon Evans on 2016-01-08.
//  Copyright © 2016 Brandon Evans. All rights reserved.
//

import Foundation

class NowPlayingPresenter: NSObject, Presenter {
    var view: NowPlayingView
    let service: AudioPlayerService

    var sound: FSHSound? {
        didSet {
            service.stop()

            guard let sound = sound else {
                view.state.hidden = true
                return
            }
            if !sound.streamable { return }

            view.state.duration = 0
            view.state.formattedDuration = ""
            view.state.progress = 0
            view.state.formattedProgress = ""
            
            view.state.trackTitle = sound.title
            view.state.author = sound.author
            view.state.favorite = sound.favorite
            view.state.permalinkURL = sound.permalinkURL

            view.state.hidden = false

            sound.fetchPlayURL().subscribeNext { [weak self] playURL in
                guard let _self = self, playURL = playURL as? NSURL else { return }
                _self.service.play(playURL)
            }
            sound.fetchWaveform().subscribeNext { [weak self] waveform in
                guard let _self = self, waveform = waveform as? FSHWaveform else { return }
                _self.view.state.waveform = waveform
            }
        }
    }

    init(view: NowPlayingView, service: AudioPlayerService) {
        self.view = view
        self.service = service

        super.init()
        
        service.state.addObserver { [weak self] state in
            self?.view.state.playing = state == .Playing
            self?.view.state.loading = state == .Loading
        }
        service.progressChangedHandler = { [weak self] progress, duration in
            self?.view.state.progress = progress
            self?.view.state.duration = duration
            self?.view.state.formattedDuration = self?.formatSeconds(Int(service.duration)) ?? ""
            self?.view.state.formattedProgress = self?.formatSeconds(Int(service.progress)) ?? ""
        }
    }

    func toggleCurrentSound() {
        if sound == nil { return }

        switch service.state.get {
        case .Playing: service.pause()
        default: service.resume()
        }
    }

    func toggleFavorite() {
        sound?.toggleFavorite()
    }

    func seekToProgress(progress: Double) {
        service.seek(progress)
    }

    func formatSeconds(totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return NSString(format:"%.2ld:%.2ld", minutes, seconds) as String
    }

    func selectedSoundChanged(sound: FSHSound?) {
        self.sound = sound
    }

    // MARK: Presenter

    func initializeView() {

    }
}