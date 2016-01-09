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
    let service: SoundCloudService
    var view: SoundListView

    init (view: SoundListView, service: SoundCloudService) {
        self.view = view
        self.service = service

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "soundEnded:", name: "FSHSoundEndedNotification", object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "FSHSoundEndedNotification", object: nil)
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

    // MARK: -

    func soundEnded(notification: NSNotification) {
        guard let sound = notification.object as? FSHSound else { return }
        let index = sounds.indexOf { $0.isEqual(sound) } ?? 0
        if index == sounds.count - 1 {
            fetchNextSounds().startWithCompleted { [weak self] in
                self?.selectSoundAtIndex(index + 1)
            }
        }
        else {
            self.selectSoundAtIndex(index + 1)
        }
    }

    // MARK: Presenter

    func initializeView() {
        updateSounds().start()
    }
}