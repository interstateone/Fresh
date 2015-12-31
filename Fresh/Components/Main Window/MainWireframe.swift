//
//  MainWireframe.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-12-29.
//  Copyright © 2015 Brandon Evans. All rights reserved.
//

class MainWireframe: NSObject {
    let service = SoundCloudService()

    lazy var windowController: FSHWindowController = {
        let windowController = FSHWindowController(windowNibName: "FSHWindow")
        let presenter = FSHWindowPresenter(wireframe: self, service: self.service)
        self.service.accountObserverSet.add(presenter, presenter.dynamicType.accountChanged)
        windowController.presenter = presenter
        return windowController
    }()

    func presentMainWindow() {
        self.windowController.showWindow(nil)
    }
}