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
    var account: FSHAccount {
        didSet {
            self.nowPlayingPresenter = FSHNowPlayingPresenter(account: account)
            self.soundListPresenter = FSHSoundListPresenter(account: account)
        }
    }
    var nowPlayingPresenter: FSHNowPlayingPresenter
    var soundListPresenter: FSHSoundListPresenter

    init(account: FSHAccount) {
        self.account = account
        self.nowPlayingPresenter = FSHNowPlayingPresenter(account: account)
        self.soundListPresenter = FSHSoundListPresenter(account: account)
        super.init()

        NSNotificationCenter.defaultCenter().rac_addObserverForName("FSHSoundCloudUserDidAuthenticate", object: nil).subscribeNext { [weak self] (_) -> Void in
            if let _self = self {
                _self.account = FSHAccount.currentAccount()
            }
        }
    }
}
