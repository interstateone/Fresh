//
//  MainWindowPresenter.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-08-06.
//  Copyright (c) 2015 Brandon Evans. All rights reserved.
//

import Foundation

class MainWindowPresenter: Presenter {
    let view: NSWindowController
    let wireframe: MainWireframe
    let service: SoundCloudService

    func selectedSoundChanged(sound: Sound?) {
        if sound != nil {
            wireframe.showNowPlaying()
        }
        else {
            wireframe.hideNowPlaying()
        }
    }

    init(view: NSWindowController, wireframe: MainWireframe, service: SoundCloudService) {
        self.view = view
        self.wireframe = wireframe
        self.service = service
    }

    // MARK: Presenter

    func initializeView() {
        wireframe.transitionToState(.Unauthenticated)
    }
}
