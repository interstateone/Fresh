//
//  MainWireframe.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-12-29.
//  Copyright © 2015 Brandon Evans. All rights reserved.
//

class MainWireframe: NSObject {
    let service = SoundCloudService()
    let audioPlayerService = AudioPlayerService()

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
        let listPresenter = SoundListPresenter(view: listViewController, service: self.service, audioPlayerService: self.audioPlayerService)
        listPresenter.view = listViewController
        listViewController.presenter = listPresenter
        listPresenter.selectedSound.addObserver(listViewController, listViewController.dynamicType.selectedSoundChanged)
        windowController.listViewController = listViewController

        let nowPlayingViewController = NowPlayingViewController(nibName: "FSHNowPlayingView", bundle: nil)!
        let nowPlayingPresenter = NowPlayingPresenter(view: nowPlayingViewController, service: self.service, audioPlayerService: self.audioPlayerService)
        nowPlayingPresenter.view = nowPlayingViewController
        nowPlayingViewController.presenter = nowPlayingPresenter
        listPresenter.selectedSound.addObserver(nowPlayingPresenter, nowPlayingPresenter.dynamicType.selectedSoundChanged)
        windowController.nowPlayingViewController = nowPlayingViewController

        let presenter = MainWindowPresenter(view: windowController, wireframe: self, service: self.service)
        self.service.accountObserverSet.add(presenter, presenter.dynamicType.accountChanged)
        listPresenter.selectedSound.addObserver(presenter, presenter.dynamicType.selectedSoundChanged)
        windowController.presenter = presenter

        return windowController
    }()

    lazy var loginViewController: FSHLoginViewController = {
        return FSHLoginViewController(nibName: "FSHLoginView", bundle: nil)!
    }()
}