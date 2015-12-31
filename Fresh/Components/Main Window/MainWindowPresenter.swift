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
        self.nowPlayingPresenter = FSHNowPlayingPresenter(account: account)
        self.soundListPresenter = FSHSoundListPresenter(service: service)
        account.soundcloudAccount != nil ? wireframe.presentSoundList() : wireframe.presentLogin()
    }
    var nowPlayingPresenter: FSHNowPlayingPresenter
    var soundListPresenter: FSHSoundListPresenter {
        willSet {
        self.willChangeValueForKey("soundListPresenter")
        }
        didSet {
        self.didChangeValueForKey("soundListPresenter")
        }
    }

    init(view: NSWindowController, wireframe: MainWireframe, service: SoundCloudService) {
        self.view = view
        self.wireframe = wireframe
        self.service = service
        self.nowPlayingPresenter = FSHNowPlayingPresenter(account: service.account)
        self.soundListPresenter = FSHSoundListPresenter(service: service)
        super.init()
    }

    // MARK: Presenter

    func initializeView() {
        service.account.soundcloudAccount != nil ? wireframe.presentSoundList() : wireframe.presentLogin()
    }
}
