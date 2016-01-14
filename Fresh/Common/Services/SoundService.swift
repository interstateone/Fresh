//
//  SoundService.swift
//  Fresh
//
//  Created by Brandon Evans on 2016-01-12.
//  Copyright © 2016 Brandon Evans. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

class SoundService {
    let service: TokenService

    init(service: TokenService) {
        self.service = service
    }

    // TODO rename fetchLatestSounds
    func updateSounds() -> SignalProducer<[Sound], NSError> {
        return service.request(SoundCloudEndpoint.Activities.request).map { result in
            let json = try! NSJSONSerialization.JSONObjectWithData(result.1, options: NSJSONReadingOptions())
            return try! [Sound].decode(JSON(json).getJSON("collection"))
        }
    }

    // TODO change .Activities to take a next URL
    func fetchNextSounds() -> SignalProducer<[Sound], NSError> {
        return service.request(SoundCloudEndpoint.Activities.request).map { result in
            let json = try! NSJSONSerialization.JSONObjectWithData(result.1, options: NSJSONReadingOptions())
            return try! [Sound].decode(JSON(json))
        }
    }
    
    func fetchPlayURL(sound: Sound) -> SignalProducer<NSURL, NSError> {
        if let playURL = sound.playURL {
            return SignalProducer(result: Result<NSURL, NSError>(value: playURL))
        }

        guard let streamURL = sound.streamURL else {
            return SignalProducer.empty
        }

        return service.request(NSURLRequest(URL: streamURL)).attemptMap { result in
            if let response = result.0 as? NSHTTPURLResponse, streamURL = response.URL {
                return Result(value: streamURL)
            }
            return Result(error: NSError(domain: "", code: 0, userInfo: nil))
        }
    }

    func fetchWaveform(sound: Sound) -> SignalProducer<Waveform, NSError> {
        guard let waveformURL = sound.waveformURL else {
            return SignalProducer.empty
        }

        return service.request(NSURLRequest(URL: waveformURL)).map { result in
            let json = try! NSJSONSerialization.JSONObjectWithData(result.1, options: NSJSONReadingOptions())
            return try! Waveform.decode(JSON(json))
        }
    }

    func toggleFavorite(sound: Sound) -> SignalProducer<Void, NSError> {
        return service.request(SoundCloudEndpoint.Favorites(favorite: !sound.favorite, trackID: sound.trackID).request).map { _ in }
    }
}