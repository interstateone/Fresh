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

    lazy var windowController: MainWindowController = {
        let windowController = MainWindowController(windowNibName: "MainWindow")

        windowController.loginViewController = self.loginViewController

        let listViewController = SoundListViewController(nibName: "SoundListView", bundle: nil)!
        let listPresenter = FSHSoundListPresenter(service: self.service)
        listPresenter.view = listViewController
        listViewController.presenter = listPresenter
        windowController.listViewController = listViewController

        let nowPlayingViewController = NowPlayingViewController(nibName: "FSHNowPlayingView", bundle: nil)!
        let nowPlayingPresenter = NowPlayingPresenter(view: nowPlayingViewController)
        nowPlayingPresenter.view = nowPlayingViewController
        nowPlayingViewController.presenter = nowPlayingPresenter
        listPresenter.selectedSoundDelegates?.addObject(nowPlayingPresenter)
        windowController.nowPlayingViewController = nowPlayingViewController

        let presenter = MainWindowPresenter(view: windowController, wireframe: self, service: self.service)
        self.service.accountObserverSet.add(presenter, presenter.dynamicType.accountChanged)
        listPresenter.selectedSoundDelegates?.addObject(presenter)
        windowController.presenter = presenter

        return windowController
    }()

    lazy var loginViewController: FSHLoginViewController = {
        return FSHLoginViewController(nibName: "FSHLoginView", bundle: nil)!
    }()
}