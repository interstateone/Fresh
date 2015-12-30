//
//  MainWireframe.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-12-29.
//  Copyright © 2015 Brandon Evans. All rights reserved.
//

class MainWireframe: NSObject {
    lazy var windowController: FSHWindowController = {
        let windowController = FSHWindowController(windowNibName: "FSHWindow")
        windowController.presenter = FSHWindowPresenter(account: FSHAccount.currentAccount())
        return windowController
    }()

    func presentMainWindow() {
        self.windowController.showWindow(nil)
    }
}