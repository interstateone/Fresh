//
//  MainWindowController.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-12-30.
//  Copyright © 2015 Brandon Evans. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    var presenter: MainWindowPresenter?

    var loginViewController: FSHLoginViewController?
    var listViewController: SoundListViewController?
    var nowPlayingViewController: NowPlayingViewController?

    override func windowDidLoad() {
        window?.title = "Fresh"
        presenter?.initializeView()
    }

    func revealNowPlayingView() {
        guard let nowPlayingViewController = nowPlayingViewController where nowPlayingViewController.parentViewController == nil else { return }

        window?.addTitlebarAccessoryViewController(nowPlayingViewController)
        window?.titleVisibility = .Hidden
    }

    func hideNowPlayingView() {
        guard let nowPlayingViewController = nowPlayingViewController where nowPlayingViewController.parentViewController != nil else { return }

        nowPlayingViewController.removeFromParentViewController()
        window?.titleVisibility = .Visible
    }

    func transitionToSoundList() {
        if let listViewController = listViewController {
            window?.contentView = listViewController.view
        }
    }

    func transitionToLogin() {
        if let loginViewController = loginViewController {
            window?.contentView = loginViewController.view
        }
    }
}
