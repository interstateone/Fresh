//
//  SoundCloudService.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-12-29.
//  Copyright © 2015 Brandon Evans. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Alamofire

typealias JSONObject = [String: AnyObject]
typealias JSONArray = [JSONObject]

class SoundCloudService: NSObject {
    var account = Account()
    var accountObserverSet = ObserverSet<Account>()
    var loggedIn: Bool {
        return account.soundcloudAccount != nil
    }
    var nextSoundsURL: NSURL?

    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserverForName(SCSoundCloudAccountDidChangeNotification, object: nil, queue: NSOperationQueue.currentQueue()) { (notification) -> Void in
            if let account = SCSoundCloud.account() {
                self.account.soundcloudAccount = account
            }
            self.willChangeValueForKey("loggedIn")
            self.didChangeValueForKey("loggedIn")
            self.accountObserverSet.notify(self.account)
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SCSoundCloudAccountDidChangeNotification, object: nil)
    }
    
    func logIn() {
        SCSoundCloud.requestAccessWithPreparedAuthorizationURLHandler { (preparedURL) -> Void in
            NSWorkspace.sharedWorkspace().openURL(preparedURL)
        }
    }

    func updateSounds() -> SignalProducer<[Sound], NSError> {
        guard loggedIn else { return SignalProducer.empty }
        return SignalProducer<[Sound], NSError> { [weak self] observer, disposal in
            guard let _self = self else {
                observer.sendCompleted()
                return
            }

            SCRequest.performMethod(SCRequestMethodGET, onResource: NSURL(string: "https://api.soundcloud.com/me/activities.json"), usingParameters: nil, withAccount: _self.account.soundcloudAccount, sendingProgressHandler: nil) { (response, data, error) -> Void in
                if error != nil {
                    observer.sendFailed(error)
                    observer.sendCompleted()
                    return
                }
                
                if let jsonResponse = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as? [String: AnyObject],
                       soundDictionaries = jsonResponse["collection"] as? JSONArray {
                    let sounds = _self.createSounds(soundDictionaries)
                    if let nextSoundsURLString = jsonResponse["next_href"] as? String {
                        _self.nextSoundsURL = NSURL(string: nextSoundsURLString)
                    }
                    observer.sendNext(sounds)
                    observer.sendCompleted()
                }
            }
        }
    }

    func fetchNextSounds() -> SignalProducer<[Sound], NSError> {
        guard loggedIn else { return SignalProducer.empty }
        return SignalProducer<[Sound], NSError> { [weak self] observer, disposal in
            guard let _self = self else {
                observer.sendCompleted()
                return
            }

            SCRequest.performMethod(SCRequestMethodGET, onResource: _self.nextSoundsURL, usingParameters: nil, withAccount: _self.account.soundcloudAccount, sendingProgressHandler: nil) { (response, data, error) -> Void in
                if error != nil {
                    observer.sendFailed(error)
                    observer.sendCompleted()
                    return
                }

                if let jsonResponse = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as? [String: AnyObject],
                       soundDictionaries = jsonResponse["collection"] as? JSONArray {
                    let sounds = _self.createSounds(soundDictionaries)
                    if let nextSoundsURLString = jsonResponse["next_href"] as? String {
                        _self.nextSoundsURL = NSURL(string: nextSoundsURLString)
                    }
                    observer.sendNext(sounds)
                    observer.sendCompleted()
                }
            }
        }
    }

    func createSounds(soundDictionaries: JSONArray) -> [Sound] {
        return soundDictionaries.filter { dictionary in
            guard let origin = dictionary["origin"] as? JSONObject else { return false }
            let streamable = (origin["streamable"] as? Bool ?? false) == true
            let isTrack = (origin["kind"] as? String ?? "") == "track"
            return streamable && isTrack
        }.map { dictionary in
            do {
                return try Sound(json: JSON(dictionary))
            }
            catch {
                NSLog("%@", "\(error)")
                return nil
            }
        }.flatMap {$0}
    }
    
    func fetchPlayURL(sound: Sound) -> SignalProducer<NSURL, NSError> {
        return SignalProducer<NSURL, NSError> { [weak self] observer, disposal in
            if let playURL = sound.playURL {
                observer.sendNext(playURL)
                observer.sendCompleted()
                return
            }
            
            self?.getStreamURL(sound) { streamURL, error in
                if let URL = streamURL {
                    sound.playURL = URL
                    observer.sendNext(URL)
                }
                else if let error = error {
                    observer.sendFailed(error)
                }
                observer.sendCompleted()
            }
        }
    }

    private func getStreamURL(sound: Sound, completion: (NSURL!, NSError!) -> Void) {
        guard let streamURL = sound.streamURL else { return }

        let request = NXOAuth2Request(resource:streamURL, method:"GET", parameters:[:])
        request.account = SCSoundCloud.account().oauthAccount
        request.performRequestWithSendingProgressHandler(nil) { (response: NSURLResponse!, data: NSData!, error: NSError!) in
            if let response = response as? NSHTTPURLResponse, URLString = response.allHeaderFields["Location"] as? String, streamURL = NSURL(string: URLString) {
                completion(streamURL, nil)
            }
            else {
                completion(nil, nil)
            }
        }
    }

    func fetchWaveform(sound: Sound) -> SignalProducer<Waveform, NSError> {
        return SignalProducer<Waveform, NSError> { observer, disposal in
            guard let waveformURL = sound.waveformURL else {
                observer.sendFailed(NSError(domain: "", code: 0, userInfo: nil))
                observer.sendCompleted()
                return
            }

            let request = NSMutableURLRequest(URL: waveformURL)
            request.HTTPShouldHandleCookies = false
            
            Alamofire.request(.GET, waveformURL).responseJSON { response in
                if let json = response.result.value, waveform = try? Waveform(json: JSON(json)) {
                    observer.sendNext(waveform)
                    observer.sendCompleted()
                    return
                }

                switch response.result {
                case .Success:
                    // TODO: JSON was bad but something was still returned
                    observer.sendFailed(NSError(domain: "", code: 0, userInfo: nil))
                    observer.sendCompleted()
                case .Failure(let error):
                    observer.sendFailed(error)
                    observer.sendCompleted()
                }
            }
        }
    }

    func toggleFavorite(sound: Sound, completion: (() -> Void)? = nil) {
        sound.favorite = !sound.favorite

        let method = sound.favorite ? "PUT" : "DELETE"
        let resource = NSURL(string:"https://api.soundcloud.com/me/favorites/\(sound.trackID)")
        let request = NXOAuth2Request(resource: resource, method: method, parameters: nil)
        request.account = SCSoundCloud.account().oauthAccount
        request.performRequestWithSendingProgressHandler(nil) { (response, data, error) in
            if error != nil {
                NSLog("%@", "Error favoriting track: \(error), favorite: \(sound.favorite)")
                sound.favorite = !sound.favorite;
            }
            completion?()
        }
    }
}