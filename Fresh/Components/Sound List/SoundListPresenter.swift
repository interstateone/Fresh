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
    let service: SoundCloudService
    let audioPlayerService: AudioPlayerService

    init (view: SoundListView, service: SoundCloudService, audioPlayerService: AudioPlayerService) {
        self.view = view
        self.service = service
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

    private var sounds = [FSHSound]() {
        didSet {
            view.rowModels = sounds.map { SoundListRowModel(title: $0.title, author: $0.author) }
        }
    }
    let selectedSound = Observable<FSHSound?>(nil)

    func updateSounds() -> SignalProducer<[FSHSound], NSError> {
        let signal = service.updateSounds().on(next: { [weak self] sounds in
            self?.sounds = sounds
        })
        return signal
    }

    func fetchNextSounds() -> SignalProducer<[FSHSound], NSError> {
        return service.fetchNextSounds()
    }

    func selectSoundAtIndex(index: Int) {
        selectedSound.set(sounds[safe: index])
    }

    var indexOfSelectedSound: Int? {
        return sounds.indexOf { $0 == self.selectedSound.get }
    }

    // MARK: Presenter

    func initializeView() {
        updateSounds().start()
    }
}