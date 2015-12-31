//
//  MainWireframe.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-12-29.
//  Copyright © 2015 Brandon Evans. All rights reserved.
//

class MainWireframe: NSObject {
    let service = SoundCloudService()

    func presentMainWindow() {
        windowController.showWindow(nil)
        presentLogin()
    }

    // MARK: Transitions

    func presentSoundList() {
        windowController.transitionToSoundList()
    }

    func presentLogin() {
        windowController.transitionToLogin()
    }

    func showNowPlaying() {
        windowController.revealNowPlayingView()
    }

    func hideNowPlaying() {
        windowController.hideNowPlayingView()
    }

    // MARK: Constructors

    lazy var windowController: FSHWindowController = {
        let windowController = FSHWindowController(windowNibName: "FSHWindow")

        windowController.loginViewController = self.loginViewController

        let nowPlayingViewController = FSHNowPlayingViewController(nibName: "FSHNowPlayingView", bundle: nil)!
        let nowPlayingPresenter = FSHNowPlayingPresenter(account: self.service.account)
        nowPlayingPresenter.view = nowPlayingViewController
        nowPlayingViewController.presenter = nowPlayingPresenter
        windowController.nowPlayingViewController = nowPlayingViewController

        let listViewController = FSHSoundListViewController(nibName: "FSHSoundListView", bundle: nil)!
        let listPresenter = FSHSoundListPresenter(service: self.service)
        listPresenter.view = listViewController
        listViewController.presenter = listPresenter
        windowController.listViewController = listViewController

        let presenter = MainWindowPresenter(view: windowController, wireframe: self, service: self.service)
        self.service.accountObserverSet.add(presenter, presenter.dynamicType.accountChanged)
        windowController.presenter = presenter

        return windowController
    }()

    lazy var loginViewController: FSHLoginViewController = {
        return FSHLoginViewController(nibName: "FSHLoginView", bundle: nil)!
    }()
}