//
//  NowPlayingPresenter.swift
//  Fresh
//
//  Created by Brandon Evans on 2016-01-08.
//  Copyright © 2016 Brandon Evans. All rights reserved.
//

import Foundation

class NowPlayingPresenter: Presenter {
    var view: NowPlayingView
    let service: SoundCloudService
    let audioPlayerService: AudioPlayerService

    var sound: Sound? {
        didSet {
            audioPlayerService.stop()

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

            service.fetchPlayURL(sound).startWithNext { [weak self] playURL in
                self?.audioPlayerService.play(playURL)
            }
            service.fetchWaveform(sound).startWithNext { [weak self] waveform in
                self?.view.state.waveform = waveform
            }
        }
    }

    init(view: NowPlayingView, service: SoundCloudService, audioPlayerService: AudioPlayerService) {
        self.view = view
        self.service = service
        self.audioPlayerService = audioPlayerService

        audioPlayerService.state.addObserver { [weak self] state in
            self?.view.state.playing = state == .Playing
            self?.view.state.loading = state == .Loading
        }
        audioPlayerService.progressChangedHandler = { [weak self] progress, duration in
            self?.view.state.progress = progress
            self?.view.state.duration = duration
            self?.view.state.formattedDuration = self?.formatSeconds(Int(audioPlayerService.duration)) ?? ""
            self?.view.state.formattedProgress = self?.formatSeconds(Int(audioPlayerService.progress)) ?? ""
        }
    }

    func toggleCurrentSound() {
        if sound == nil { return }

        switch audioPlayerService.state.get {
        case .Playing: audioPlayerService.pause()
        default: audioPlayerService.resume()
        }
    }
    
    func toggleFavorite() {
        if let sound = sound {
            service.toggleFavorite(sound) { [weak self] in
                // In case the change failed, set the view state on completion too
                self?.view.state.favorite = sound.favorite
            }
            view.state.favorite = sound.favorite
        }
    }

    func seekToProgress(progress: Double) {
        audioPlayerService.seek(progress)
    }

    func formatSeconds(totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return NSString(format:"%.2ld:%.2ld", minutes, seconds) as String
    }

    func selectedSoundChanged(sound: Sound?) {
        self.sound = sound
    }

    // MARK: Presenter

    func initializeView() {

    }
}