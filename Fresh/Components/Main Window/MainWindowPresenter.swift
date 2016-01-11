//
//  MainWindowPresenter.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-08-06.
//  Copyright (c) 2015 Brandon Evans. All rights reserved.
//

import Foundation
import ReactiveCocoa

class MainWindowPresenter: NSObject, Presenter {
    let view: NSWindowController
    let wireframe: MainWireframe
    let service: SoundCloudService

    func accountChanged(account: FSHAccount) {
        account.soundcloudAccount != nil ? wireframe.presentSoundList() : wireframe.presentLogin()
    }
    
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
        super.init()
    }

    // MARK: Presenter

    func initializeView() {
        service.account.soundcloudAccount != nil ? wireframe.presentSoundList() : wireframe.presentLogin()
    }
}
