//
//  SoundListPresenter.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-12-30.
//  Copyright © 2015 Brandon Evans. All rights reserved.
//

import Foundation
import ReactiveCocoa

class SoundListPresenter: Presenter {
    var view: SoundListView
    var service: SoundService? = nil
    let audioPlayerService: AudioPlayerService

    init (view: SoundListView, audioPlayerService: AudioPlayerService) {
        self.view = view
        self.audioPlayerService = audioPlayerService
        
        audioPlayerService.state.addObserver { [weak self] state in
            guard let _self = self, index = _self.indexOfSelectedSound where state == .Finished else { return }

            if index == _self.sounds.count - 1 {
                _self.fetchNextSounds().startWithCompleted {
                    _self.selectSoundAtIndex(index + 1)
                }
            }
            else {
                _self.selectSoundAtIndex(index + 1)
            }
        }
    }

    private var sounds = [Sound]() {
        didSet {
            view.rowModels = sounds.map { SoundListRowModel(title: $0.title, author: $0.author) }
        }
    }
    let selectedSound = Observable<Sound?>(nil)

    func updateSounds() -> SignalProducer<[Sound], NSError> {
        guard let service = service else {
            return SignalProducer.empty
        }
        let signal = service.updateSounds().on(next: { [weak self] sounds in
            self?.sounds = sounds
        })
        return signal
    }

    func fetchNextSounds() -> SignalProducer<[Sound], NSError> {
        guard let service = service else {
            return SignalProducer.empty
        }
        return service.fetchNextSounds()
    }

    func selectSoundAtIndex(index: Int) {
        selectedSound.set(sounds[safe: index])
    }

    var indexOfSelectedSound: Int? {
        return sounds.indexOf { $0 == self.selectedSound.get }
    }

    func authenticationStateChanged(authenticationState: AuthenticationState) {
        switch authenticationState {
        case .Unauthenticated: service = nil
        case .Authenticated(let service): self.service = SoundService(service: service)
        }
    }

    // MARK: Presenter

    func initializeView() {
        updateSounds().start()
    }
}