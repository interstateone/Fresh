//
//  FSHWindowViewModel.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-08-06.
//  Copyright (c) 2015 Brandon Evans. All rights reserved.
//

import Foundation
import ReactiveCocoa

class FSHWindowViewModel: NSObject {
    var account: FSHAccount {
        didSet {
            self.nowPlayingViewModel = FSHNowPlayingViewModel(account: account)
            self.soundListViewModel = FSHSoundListViewModel(account: account)
        }
    }
    var nowPlayingViewModel: FSHNowPlayingViewModel
    var soundListViewModel: FSHSoundListViewModel

    init(account: FSHAccount) {
        self.account = account
        self.nowPlayingViewModel = FSHNowPlayingViewModel(account: account)
        self.soundListViewModel = FSHSoundListViewModel(account: account)
        super.init()

        NSNotificationCenter.defaultCenter().rac_addObserverForName("FSHSoundCloudUserDidAuthenticate", object: nil).subscribeNext { [weak self] (_) -> Void in
            if let _self = self {
                _self.account = FSHAccount.currentAccount()
            }
        }
    }
}
