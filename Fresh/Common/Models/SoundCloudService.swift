//
//  SoundCloudService.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-12-29.
//  Copyright © 2015 Brandon Evans. All rights reserved.
//

import Foundation
import ReactiveCocoa

typealias JSONObject = [String: AnyObject]
typealias JSONArray = [JSONObject]

class SoundCloudService: NSObject {
    var account = FSHAccount()
    var accountObserverSet = ObserverSet<FSHAccount>()
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

    func updateSounds() -> RACSignal { // SignalProducer<[FSHSound], NSError> {
        guard loggedIn else { return RACSignal.empty() }
        return SignalProducer<NSArray, NSError> { [weak self] observer, disposal in
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
        }.toRACSignal()
    }

    func fetchNextSounds() -> RACSignal { // -> SignalProducer<[FSHSound], NSError> {
        guard loggedIn else { return RACSignal.empty() }
        return SignalProducer<NSArray, NSError> { [weak self] observer, disposal in
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
        }.toRACSignal()
    }

    func createSounds(soundDictionaries: JSONArray) -> [FSHSound] {
        return soundDictionaries.filter { dictionary in
            guard let origin = dictionary["origin"] as? JSONObject else { return false }
            let streamable = (origin["streamable"] as? Bool ?? false) == true
            let isTrack = (origin["kind"] as? String ?? "") == "track"
            return streamable && isTrack
        }.map { dictionary in
            return (try? MTLJSONAdapter.modelOfClass(FSHSound.self, fromJSONDictionary: dictionary)) as? FSHSound
        }.flatMap {$0}
    }
}