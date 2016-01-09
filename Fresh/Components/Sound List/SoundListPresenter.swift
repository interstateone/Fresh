//
//  SoundListPresenter.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-12-30.
//  Copyright © 2015 Brandon Evans. All rights reserved.
//

import Foundation
import ReactiveCocoa

protocol SelectedSoundDelegate {
    func selectedSoundChanged(sound: FSHSound?)
}

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

    var selectedSoundDelegates = [SelectedSoundDelegate]()
    private var sounds = [FSHSound]() {
        didSet {
            view.rowModels = sounds.map { SoundListRowModel(title: $0.title, author: $0.author) }
        }
    }
    var selectedSound: FSHSound? = nil {
        didSet {
            for delegate in selectedSoundDelegates {
                delegate.selectedSoundChanged(selectedSound)
            }
        }
    }

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
        selectedSound = soundAtIndex(index)
    }

    var indexOfSelectedSound: Int? {
        return sounds.indexOf { $0.isEqual(self.selectedSound) }
    }

    private func soundAtIndex(index: Int) -> FSHSound? {
        if index < 0 || index > sounds.count - 1 { return nil }
        return sounds[index]
    }

    // MARK: Presenter

    func initializeView() {
        updateSounds().start()
    }
}