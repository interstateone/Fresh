//
//  FSHWindowPresenter.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-08-06.
//  Copyright (c) 2015 Brandon Evans. All rights reserved.
//

import Foundation
import ReactiveCocoa

class FSHWindowPresenter: NSObject {
    let wireframe: MainWireframe
    let service: SoundCloudService

    func accountChanged(account: FSHAccount) {
        self.nowPlayingPresenter = FSHNowPlayingPresenter(account: account)
        self.soundListPresenter = FSHSoundListPresenter(service: service)
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

    init(wireframe: MainWireframe, service: SoundCloudService) {
        self.wireframe = wireframe
        self.service = service
        self.nowPlayingPresenter = FSHNowPlayingPresenter(account: service.account)
        self.soundListPresenter = FSHSoundListPresenter(service: service)
        super.init()
    }
}
