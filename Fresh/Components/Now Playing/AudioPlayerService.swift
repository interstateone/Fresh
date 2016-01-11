//
//  AudioPlayerService.swift
//  Fresh
//
//  Created by Brandon Evans on 2016-01-08.
//  Copyright © 2016 Brandon Evans. All rights reserved.
//

import Foundation

public class AudioPlayerService: NSObject, STKAudioPlayerDelegate {
    private let audioPlayer = STKAudioPlayer()
    
    public var progress: Double = 0 {
        didSet {
            progressChangedHandler?(progress, duration)
        }
    }
    public var duration: Double = 0 {
        didSet {
            progressChangedHandler?(progress, duration)
        }
    }
    public var errorHandler: ((ErrorType) -> Void)? = nil
    public var progressChangedHandler: ((Double, Double) -> Void)? = nil
    
    public let state = Observable<State>(.Ready)
    private var _state = State.Ready {
        didSet {
            if _state == oldValue { return }

            state.set(_state)

            switch _state {
            case .Playing where updateTimer == nil:
                updateTimer = Timer(interval: 0.25, tolerance: 0.25, repeats: true, handler: update)
            default:
                updateTimer?.stop()
                updateTimer = nil
            }
        }
    }
    public enum State: String, CustomStringConvertible {
        case Ready = "Ready"
        case Loading = "Loading"
        case Playing = "Playing"
        case Paused = "Paused"
        case Finished = "Finished"
        case Stopped = "Stopped"

        public var description: String {
            return self.rawValue
        }
    }

    public override init() {
        super.init()
        audioPlayer.delegate = self
    }

    deinit {
        updateTimer?.stop()
    }

    public func play(URL: NSURL) {
        audioPlayer.playURL(URL)
    }

    public func pause() {
        audioPlayer.pause()
    }

    public func resume() {
        audioPlayer.resume()
    }

    public func stop() {
        audioPlayer.stop()
    }

    public func seek(time: Double) {
        audioPlayer.seekToTime(time)
    }

    private var updateTimer: Timer? = nil
    func update() {
        if _state != .Playing { return }
        progress = audioPlayer.progress
        duration = audioPlayer.duration
    }

    // MARK: STKAudioPlayerDelegate

    public func audioPlayer(audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        // TODO: Reset UI in this situation
        NSLog("StreamingKit unexpected error: %d", errorCode.rawValue);
    }

    public func audioPlayer(audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
    }

    public func audioPlayer(audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, withReason stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        if stopReason == .Eof {
            _state = .Finished
        }
    }

    public func audioPlayer(audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
    }

    public func audioPlayer(audioPlayer: STKAudioPlayer, stateChanged state:STKAudioPlayerState, previousState: STKAudioPlayerState) {
        switch state {
        case STKAudioPlayerState.Ready:
            _state = .Ready
        case STKAudioPlayerState.Running:
            _state = .Playing
        case STKAudioPlayerState.Playing:
            _state = .Playing
        case STKAudioPlayerState.Buffering:
            _state = .Loading
        case STKAudioPlayerState.Paused:
            _state = .Paused
        case STKAudioPlayerState.Stopped:
            _state = .Stopped
        case STKAudioPlayerState.Error:
            _state = .Stopped
        case STKAudioPlayerState.Disposed:
            _state = .Stopped
        default: break;
        }
    }
}