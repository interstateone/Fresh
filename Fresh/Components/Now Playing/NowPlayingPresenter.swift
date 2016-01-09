//
//  NowPlayingPresenter.swift
//  Fresh
//
//  Created by Brandon Evans on 2016-01-08.
//  Copyright © 2016 Brandon Evans. All rights reserved.
//

import Foundation

@objc class NowPlayingPresenter: NSObject, Presenter, SelectedSoundDelegate, STKAudioPlayerDelegate {
    var view: NowPlayingView
    var sound: FSHSound? {
        didSet {
            guard let sound = sound else {
                view.state.hidden = true
                updateTimer?.stop()
                return
            }
            if !sound.streamable { return }

            audioPlayer.stop()

            view.state.duration = 0
            view.state.formattedDuration = ""
            view.state.progress = 0
            view.state.formattedProgress = ""
            
            view.state.trackTitle = sound.title
            view.state.author = sound.author
            view.state.favorite = sound.favorite
            view.state.permalinkURL = sound.permalinkURL

            view.state.hidden = false
            updateTimer = Timer(interval: 0.25, tolerance: 0.25, repeats: true, handler: updateUIProgress)

            sound.fetchPlayURL().subscribeNext { [weak self] playURL in
                guard let _self = self, playURL = playURL as? NSURL else { return }
                _self.audioPlayer.play(playURL.absoluteString)
                _self.view.state.duration = _self.audioPlayer.duration
            }
            sound.fetchWaveform().subscribeNext { [weak self] waveform in
                guard let _self = self, waveform = waveform as? FSHWaveform else { return }
                _self.view.state.waveform = waveform
            }
        }
    }
    private let audioPlayer = STKAudioPlayer()
    private var updateTimer: Timer? = nil

    init(view: NowPlayingView) {
        self.view = view
        super.init()
        audioPlayer.delegate = self
    }

    deinit {
        updateTimer?.stop()
    }

    func toggleCurrentSound() {
        if sound == nil { return }

        switch audioPlayer.state {
        case STKAudioPlayerState.Playing: audioPlayer.pause()
        default: audioPlayer.resume()
        }
    }

    func toggleFavorite() {
        sound?.toggleFavorite()
    }

    func seekToProgress(progress: Double) {
        audioPlayer.seekToTime(progress)
    }
    
    func updateUIProgress() {
        if self.audioPlayer.state != STKAudioPlayerState.Playing { return }

        view.state.progress = audioPlayer.progress;
        view.state.duration = audioPlayer.duration;
        view.state.formattedDuration = formatSeconds(Int(audioPlayer.duration))
        view.state.formattedProgress = formatSeconds(Int(audioPlayer.progress))
    }
    
    func formatSeconds(totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return NSString(format:"%.2ld:%.2ld", minutes, seconds) as String
    }

    // MARK: SelectedSoundDelegate

    func selectedSoundChanged(sound: FSHSound!) {
        self.sound = sound
    }

    // MARK: Presenter

    func initializeView() {

    }

    // MARK: STKAudioPlayerDelegate

    func audioPlayer(audioPlayer: STKAudioPlayer!, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        // TODO: Reset UI in this situation
        NSLog("StreamingKit unexpected error: %d", errorCode.rawValue);
    }

    func audioPlayer(audioPlayer: STKAudioPlayer!, didStartPlayingQueueItemId queueItemId: NSObject!) {
    }

    func audioPlayer(audioPlayer: STKAudioPlayer!, didFinishPlayingQueueItemId queueItemId: NSObject!, withReason stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        if let sound = sound where stopReason == .Eof {
            NSNotificationCenter.defaultCenter().postNotificationName("FSHSoundEndedNotification", object:sound, userInfo:nil)
        }
    }

    func audioPlayer(audioPlayer: STKAudioPlayer!, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject!) {
    }

    func audioPlayer(audioPlayer: STKAudioPlayer!, stateChanged state:STKAudioPlayerState, previousState: STKAudioPlayerState) {
        view.state.playing = state == .Playing
        view.state.loading = state == .Buffering
    }
}