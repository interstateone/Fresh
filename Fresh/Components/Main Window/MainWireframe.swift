//
//  MainWireframe.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-12-29.
//  Copyright © 2015 Brandon Evans. All rights reserved.
//

enum AuthenticationState {
    case Unauthenticated
    case Authenticated(tokenService: TokenService)
}

class MainWireframe: NSObject {
    private let service = SoundCloudService()
    private let audioPlayerService = AudioPlayerService()
    private let oAuthConfiguration = OAuthConfiguration(appID: "***REMOVED***", appSecret: "***REMOVED***", redirectURL: NSURL(string: "freshapp://oauth")!)
    var authenticationState = Observable<AuthenticationState>(.Unauthenticated)

    func presentMainWindow() {
        windowController.showWindow(nil)
        windowController.transitionToLogin()
    }

    // MARK: Transitions

    func transitionToState(state: AuthenticationState) {
        switch (self.authenticationState.get, state) {
        case (.Authenticated, .Unauthenticated):
            windowController.transitionToLogin()
        case (.Unauthenticated, .Authenticated):
            windowController.transitionToSoundList()
            hideNowPlaying()
        default: break
        }

        self.authenticationState.set(state)
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
        let listPresenter = SoundListPresenter(view: listViewController, audioPlayerService: self.audioPlayerService)
        self.authenticationState.addObserver(listPresenter, listPresenter.dynamicType.authenticationStateChanged)
        listPresenter.view = listViewController
        listViewController.presenter = listPresenter
        listPresenter.selectedSound.addObserver(listViewController, listViewController.dynamicType.selectedSoundChanged)
        windowController.listViewController = listViewController

        let nowPlayingViewController = NowPlayingViewController(nibName: "FSHNowPlayingView", bundle: nil)!
        let nowPlayingPresenter = NowPlayingPresenter(view: nowPlayingViewController, audioPlayerService: self.audioPlayerService)
        self.authenticationState.addObserver(nowPlayingPresenter, nowPlayingPresenter.dynamicType.authenticationStateChanged)
        nowPlayingPresenter.view = nowPlayingViewController
        nowPlayingViewController.presenter = nowPlayingPresenter
        listPresenter.selectedSound.addObserver(nowPlayingPresenter, nowPlayingPresenter.dynamicType.selectedSoundChanged)
        windowController.nowPlayingViewController = nowPlayingViewController

        let presenter = MainWindowPresenter(view: windowController, wireframe: self, service: self.service)
        listPresenter.selectedSound.addObserver(presenter, presenter.dynamicType.selectedSoundChanged)
        windowController.presenter = presenter

        return windowController
    }()

    lazy var loginViewController: LoginViewController = {
        let loginViewController = LoginViewController(nibName: "LoginView", bundle: nil)!
        loginViewController.presenter = LoginPresenter(view: loginViewController, configuration: self.oAuthConfiguration) { [weak self] authentication in
            let networkService = NetworkService(session: NSURLSession.sharedSession())
            self?.transitionToState(.Authenticated(tokenService: TokenService(authentication: authentication, service: networkService)))
        }
        return loginViewController
    }()
}